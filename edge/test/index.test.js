import assert from 'node:assert/strict';
import { beforeEach, test } from 'node:test';

import { handle, normalisedSearch } from '../src/index.js';

const ENV = { ORIGIN: 'https://hatua-api.vercel.app', FRESH_SECONDS: '300', STALE_SECONDS: '3600', ORIGIN_TIMEOUT_MS: '50' };
const LISTINGS = JSON.stringify([{ id: '1', title: 'Example only' }]);

/** Minimal stand-in for the Workers Cache API keyed by URL. */
class FakeCache {
  store = new Map();
  async match(request) {
    const hit = this.store.get(request.url);
    return hit ? hit.clone() : undefined;
  }
  async put(request, response) {
    this.store.set(request.url, response.clone());
  }
}

let cache, calls, now, ctx, originResponder;

beforeEach(() => {
  cache = new FakeCache();
  calls = [];
  now = 1_000_000;
  const pending = [];
  ctx = { waitUntil: (p) => pending.push(p), settle: () => Promise.all(pending) };
  originResponder = () => new Response(LISTINGS, { status: 200, headers: { 'content-type': 'application/json' } });
});

const fetchImpl = async (url, init) => {
  calls.push({ url, init });
  return originResponder(url, init);
};

async function get(path, init = {}) {
  const response = await handle(new Request(`https://hatua-api.example.workers.dev${path}`, init), ENV, ctx, {
    cache,
    fetchImpl,
    now: () => now,
  });
  await ctx.settle();
  return response;
}

test('first request goes to the origin, second is served from the edge', async () => {
  const first = await get('/api/v1/opportunities/');
  assert.equal(first.status, 200);
  assert.equal(first.headers.get('x-hatua-cache'), 'MISS');
  assert.equal(await first.text(), LISTINGS);

  now += 299_000;
  const second = await get('/api/v1/opportunities/');
  assert.equal(second.headers.get('x-hatua-cache'), 'HIT');
  assert.equal(second.headers.get('age'), '299');
  assert.equal(await second.text(), LISTINGS);
  assert.equal(calls.length, 1);
  assert.equal(second.headers.get('x-hatua-stored-at'), null, 'internal header must not leak');
});

test('after FRESH_SECONDS the origin is asked again (revocations reach users within 5 minutes)', async () => {
  await get('/api/v1/opportunities/');
  now += 300_000;
  originResponder = () => new Response('[]', { status: 200, headers: { 'content-type': 'application/json' } });
  const res = await get('/api/v1/opportunities/');
  assert.equal(res.headers.get('x-hatua-cache'), 'MISS');
  assert.equal(await res.text(), '[]');
  assert.equal(calls.length, 2);
});

test('origin down: serves the last good copy within STALE_SECONDS, then gives up', async () => {
  await get('/api/v1/support-resources/');
  now += 600_000;
  originResponder = () => new Response('boom', { status: 503 });
  const stale = await get('/api/v1/support-resources/');
  assert.equal(stale.status, 200);
  assert.equal(stale.headers.get('x-hatua-cache'), 'STALE');
  assert.equal(await stale.text(), LISTINGS);

  now += 3_600_000;
  const gone = await get('/api/v1/support-resources/');
  assert.equal(gone.status, 503);
});

test('origin timeout with nothing cached returns 502 JSON', async () => {
  originResponder = (_url, init) =>
    new Promise((_resolve, reject) => init.signal.addEventListener('abort', () => reject(new Error('aborted'))));
  const res = await get('/api/v1/opportunities/');
  assert.equal(res.status, 502);
  assert.equal(res.headers.get('x-hatua-cache'), 'ERROR');
});

test('client errors pass through and are never cached', async () => {
  originResponder = () => new Response('{"category":"bad"}', { status: 400 });
  const first = await get('/api/v1/opportunities/?category=casino');
  assert.equal(first.status, 400);
  await get('/api/v1/opportunities/?category=casino');
  assert.equal(calls.length, 2);
  assert.equal(cache.store.size, 0);
});

test('health is never cached', async () => {
  await get('/api/v1/health/');
  await get('/api/v1/health/');
  assert.equal(calls.length, 2);
  assert.equal(cache.store.size, 0);
});

test('admin, other paths and writes are refused; nothing is proxied', async () => {
  assert.equal((await get('/admin/')).status, 404);
  assert.equal((await get('/staff-portal/login/')).status, 404);
  assert.equal((await get('/api/v1/opportunities/', { method: 'POST', body: '{}' })).status, 405);
  assert.equal(calls.length, 0);
});

test('client cookies and auth are not forwarded; Set-Cookie from origin is dropped', async () => {
  originResponder = () =>
    new Response(LISTINGS, { status: 200, headers: { 'content-type': 'application/json', 'set-cookie': 'x=1' } });
  const res = await get('/api/v1/opportunities/', { headers: { cookie: 'sessionid=secret', authorization: 'Bearer t' } });
  const sent = new Headers(calls[0].init.headers);
  assert.equal(sent.get('cookie'), null);
  assert.equal(sent.get('authorization'), null);
  assert.equal(res.headers.get('set-cookie'), null);
});

test('unknown query parameters are dropped and known ones normalised into one cache key', async () => {
  await get('/api/v1/opportunities/?utm_source=x&county=Kisumu&category=job');
  await get('/api/v1/opportunities/?category=job&county=Kisumu&cachebust=123');
  assert.equal(calls.length, 1);
  assert.equal(calls[0].url, 'https://hatua-api.vercel.app/api/v1/opportunities/?category=job&county=Kisumu');
  assert.equal(normalisedSearch(new URLSearchParams('q=%20%20')), '');
});

test('HEAD returns headers without a body', async () => {
  const res = await get('/api/v1/opportunities/', { method: 'HEAD' });
  assert.equal(res.status, 200);
  assert.equal(await res.text(), '');
});

test('refuses to run with a non-https origin', async () => {
  await assert.rejects(
    handle(new Request('https://w.example/api/v1/opportunities/'), { ORIGIN: 'http://insecure.example' }, ctx, {
      cache,
      fetchImpl,
      now: () => now,
    }),
    /ORIGIN must be an https/,
  );
});
