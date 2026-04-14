# Agents

## GitHub Actions CI/CD

Workflow: `.github/workflows/ci.yml`
Trigger: push or PR to `main`

### Check job (all branches)

Runs five quality gates, all must pass:

1. **RSpec** — unit and integration tests
2. **RuboCop** — style and lint enforcement
3. **Brakeman** — static security analysis
4. **bundle-audit** — dependency vulnerability scan
5. **libyear-bundler** — dependency freshness metric

Results are uploaded as CI artifacts (90-day retention).

On `main` push only, a **Solana memo transaction** attests the build
on-chain (best-effort; does not block deployment).

### Deploy job (main only)

Runs after check passes. Executes `bin/deploy` which:

1. Writes REVISION file (git short SHA)
2. Bundles production gems
3. Packages and uploads zip to S3
4. Updates the Lambda function
5. Invalidates the CloudFront cache

### Credentials

- AWS access via OIDC role (`secrets.AWS_ROLE_ARN`)
- Solana keypair loaded from `secrets.SOLANA_KEYPAIR`, cleaned up after use
