/**
 * HATUA edge cache (Cloudflare Worker).
 *
 * Sits in front of the Django API on Vercel and serves ONLY the public, read-only
 * directory under /api/v1/. It never proxies the staff admin, never forwards client
 * cookies or auth headers, and never caches anything except successful public JSON.
 *
 *   fresh  (age < FRESH_SECONDS)                  -> served from cache       (x-hatua-cache: HIT)
 *   stale  -> ask origin; 200                     -> refresh cache           (MISS)
 *          -> origin 5xx / timeout, copy < STALE  -> serve last good copy    (STALE)
 *   health endpoint                               -> always from origin      (BYPASS)
 */

const API_PREFIX = '/api/v1/';
const NEVER_CACHED = new Set(['/api/v1/health/']);
/** Query parameters the API understands; anything else is dropped so it cannot fragment the cache. */
const ALLOWED_PARAMS = ['category', 'county', 'kind', 'q'];
const STORED_AT = 'x-hatua-stored-at';

export default {
  async fetch(request, env, ctx) {
    return handle(request, env, ctx, { cache: caches.default, fetchImpl: fetch, now: () => Date.now() });
  },
};

export async function handle(request, env, ctx, deps) {
  const settings = readSettings(env);
  const url = new URL(request.url);

  if (url.pathname === '/' || url.pathname === '') {
    return json({ service: 'hatua-edge', api: `${url.origin}${API_PREFIX}`, cacheSeconds: settings.fresh });
  }
  if (!url.pathname.startsWith(API_PREFIX)) {
    return json({ detail: 'Not found.' }, 404);
  }
  if (request.method !== 'GET' && request.method !== 'HEAD') {
    return json({ detail: 'Method not allowed.' }, 405, { Allow: 'GET, HEAD' });
  }

  const originUrl = new URL(url.pathname, settings.origin);
  originUrl.search = normalisedSearch(url.searchParams);
  const head = request.method === 'HEAD';
  // A fresh request: client cookies, auth and IP-revealing headers are not forwarded.
  const upstream = () =>
    fetchWithTimeout(deps.fetchImpl, originUrl.toString(), settings.timeoutMs, {
      method: 'GET',
      headers: { Accept: 'application/json', 'User-Agent': 'hatua-edge/1' },
    });

  if (NEVER_CACHED.has(url.pathname)) {
    try {
      return finalise(await upstream(), 'BYPASS', 0, head);
    } catch {
      return json({ detail: 'Upstream unavailable.' }, 502, { 'x-hatua-cache': 'ERROR' });
    }
  }

  const cacheKey = new Request(originUrl.toString(), { method: 'GET' });
  const cached = await deps.cache.match(cacheKey);
  const ageSeconds = cached ? (deps.now() - Number(cached.headers.get(STORED_AT) || 0)) / 1000 : Infinity;

  if (cached && ageSeconds >= 0 && ageSeconds < settings.fresh) {
    return finalise(cached, 'HIT', ageSeconds, head);
  }

  let response;
  try {
    response = await upstream();
  } catch {
    response = null;
  }

  if (response && response.status === 200) {
    const body = await response.arrayBuffer();
    const stored = new Response(body, {
      status: 200,
      headers: {
        'content-type': response.headers.get('content-type') || 'application/json',
        'cache-control': `public, max-age=${settings.stale}`,
        [STORED_AT]: String(deps.now()),
      },
    });
    ctx.waitUntil(deps.cache.put(cacheKey, stored.clone()));
    return finalise(stored, 'MISS', 0, head);
  }

  const originFailed = !response || response.status >= 500;
  if (originFailed && cached && ageSeconds >= 0 && ageSeconds < settings.stale) {
    return finalise(cached, 'STALE', ageSeconds, head);
  }
  if (response) {
    // 4xx (e.g. 400 for an unknown category) or a 5xx with no usable copy: pass through, never cache.
    return finalise(response, 'MISS', 0, head);
  }
  return json({ detail: 'Upstream unavailable.' }, 502, { 'x-hatua-cache': 'ERROR' });
}

function readSettings(env) {
  const origin = String(env.ORIGIN || '').replace(/\/+$/, '');
  if (!/^https:\/\//.test(origin)) throw new Error('ORIGIN must be an https:// URL');
  return {
    origin,
    fresh: positiveInt(env.FRESH_SECONDS, 300),
    stale: positiveInt(env.STALE_SECONDS, 3600),
    timeoutMs: positiveInt(env.ORIGIN_TIMEOUT_MS, 8000),
  };
}

function positiveInt(value, fallback) {
  const n = Number.parseInt(value, 10);
  return Number.isFinite(n) && n > 0 ? n : fallback;
}

export function normalisedSearch(params) {
  const kept = new URLSearchParams();
  for (const name of ALLOWED_PARAMS) {
    const value = params.get(name);
    if (value !== null && value.trim() !== '') kept.set(name, value.trim().slice(0, 100));
  }
  const text = kept.toString();
  return text ? `?${text}` : '';
}

async function fetchWithTimeout(fetchImpl, url, timeoutMs, init) {
  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), timeoutMs);
  try {
    return await fetchImpl(url, { ...init, signal: controller.signal });
  } finally {
    clearTimeout(timer);
  }
}

function finalise(response, status, ageSeconds, head) {
  const headers = new Headers(response.headers);
  headers.delete(STORED_AT);
  headers.delete('set-cookie');
  headers.set('x-hatua-cache', status);
  headers.set('cache-control', 'no-cache');
  if (status === 'HIT' || status === 'STALE') headers.set('age', String(Math.floor(ageSeconds)));
  return new Response(head ? null : response.body, { status: response.status, headers });
}

function json(body, status = 200, extraHeaders = {}) {
  return new Response(JSON.stringify(body), {
    status,
    headers: { 'content-type': 'application/json', 'cache-control': 'no-cache', ...extraHeaders },
  });
}
