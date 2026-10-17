# GitHub setup

**Repository:** https://github.com/MadScie254/hatua (created by the owner on 2026-10-18).

- Default branch `main`. Work lands through pull requests from `claude/*` or feature branches.
- GitHub currently reports the repository as **public**. The README asks for private until privacy, branding and licensing are settled. The owner should decide: Settings → General → Danger Zone → Change visibility.
- No licence file yet (all rights reserved).

## GitHub Actions

Workflows: `.github/workflows/backend.yml`, `.github/workflows/flutter.yml` (see `docs/BUILD_GUIDE.md`).

On 2026-10-18 the first runs were refused with *"The job was not started because your account is locked due to a billing issue."* Resolve this under GitHub Settings → Billing and plans, then re-run the checks from the pull request.

Suggested branch protection on `main` once CI runs: require the `test`, `analyze-test` and `build-debug-apk` checks, and require a pull request before merging.

## Authentication

Use GitHub's recommended login flow or credential manager. Never paste a Personal Access Token into this repository or an AI chat.

## Sanity checks

```bash
git status --short
git log -1 --oneline
git remote -v
```
