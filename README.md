# BAA or Not?

A simple web application that helps determine whether a
[Business Associate Agreement](https://www.hhs.gov/hipaa/for-professionals/covered-entities/sample-business-associate-agreement-provisions/index.html)
(BAA) is required under
[HIPAA](https://www.hhs.gov/hipaa/index.html).

**For entertainment and educational purposes only.** This tool does not
provide legal advice. Consult qualified counsel for binding
determinations.

## How it works

The app walks through three sequential questions derived from the HIPAA
BAA decision flow:

1. Are you a HIPAA **Covered Entity** or **Business Associate**?
2. Does the application create, receive, maintain, or transmit **PHI**?
3. Do third-party vendors process, store, or transmit that PHI for you?

If all three answers are "yes," a BAA is typically required with those
vendors. Otherwise, the tool explains why one may not be needed and
recommends documenting the rationale.

## Stack

- **Framework:** [Sinatra](https://sinatrarb.com/) 4.x (Ruby)
- **Runtime:** AWS Lambda via [Lamby](https://lamby.cloud/) 5.x
- **Hosting:** CloudFront on [clubstraylight.com](https://clubstraylight.com)
  (infrastructure managed in [form-terra](https://github.com/doolin/form-terra))
- **Web server (local):** [Puma](https://puma.io/) 7.x

## Development

```sh
bundle install
bundle exec rackup config.ru -p 4567 -o 0.0.0.0
```

Visit `http://localhost:4567/baa-or-not`.

## Quality gates

All gates run in CI on every push and pull request to `main`.

| Tool | Purpose |
|------|---------|
| [RSpec](https://rspec.info/) | Unit and integration tests |
| [RuboCop](https://rubocop.org/) | Style and complexity (strict: 8-line methods, 50-line classes) |
| [Brakeman](https://brakemanscanner.org/) | Static security analysis for Ruby web apps |
| [bundle-audit](https://github.com/rubysec/bundler-audit) | Known vulnerability scanning for gems |
| [libyear-bundler](https://github.com/jaredbeck/libyear-bundler) | Dependency freshness metric |

```sh
bundle exec rspec
bundle exec rubocop
bundle exec brakeman --force --no-pager --quiet
bundle exec bundle-audit check --update
bundle exec libyear-bundler
```

## Build SHA

Each deployment stamps a `REVISION` file with the short git commit SHA.
The SHA is displayed in the page footer for traceability. This is
primarily for entertainment purposes.

## Solana build attestation

On passing CI/CD for the `main` branch, the pipeline optionally records
a Solana memo transaction attesting to the successful build. This
creates an immutable, publicly verifiable record that a specific commit
passed all quality gates. The attestation includes the commit hash,
timestamp, and artifact checksum.

## Deployment

Deployed as an AWS Lambda function behind the clubstraylight.com
CloudFront distribution. The Lambda is provisioned via Terraform in
`form-terra`; this repo only manages application code.

```sh
bin/build    # writes REVISION
bin/deploy   # packages, uploads to S3, updates Lambda
```

## License

MIT
