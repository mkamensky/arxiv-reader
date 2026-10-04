# UPDATE

    bundle update
    npm update

# RUN IN DEV

    overmind s

# TEST

Backend:

    rake spec

Frontend:

    npm test

# UPDATE PAPERS FROM ARXIV

    rake db:seed:from_arxiv

On the web server with RAILS_ENV, daily in a systemd timer

# DEPLOY

Install on host the correct ruby version (`cat .ruby-version`), if necessary:

    # as `deploy`
    rbenv update
    rbenv install <ver>
    rbenv global <ver>

Then:

    cap production deploy

## Automatic production deployment

Pushing to `master` runs the GitHub Actions verification suite, then deploys that
exact commit to `dibbler.verymad.net` with Capistrano. The workflow can also be
started manually from the Actions tab. Failed verification prevents deployment.
Only one production workflow runs at a time.

Before enabling it, configure the `production` GitHub Actions environment with
these secrets (repository secrets also work):

- `DEPLOY_SSH_KEY`: a private SSH key whose public key is authorized for the
  `deploy` user on `dibbler.verymad.net`. Use a dedicated, passphrase-free key
  for CI, not a personal key.
- `DEPLOY_KNOWN_HOSTS`: the verified SSH host-key line(s) for
  `dibbler.verymad.net`. Obtain them with `ssh-keyscan`, but compare their
  fingerprints with the server's actual host keys through a trusted channel
  before saving them. The workflow prints the public fingerprint and checks
  that Net::SSH can read the entry. Do not disable host-key verification.
- `REPO_SSH_KEY` (optional): a separate read-only GitHub deploy key for this
  repository if the server cannot already fetch `git@github.com:mkamensky/arxiv-reader.git`.
  Capistrano forwards the runner's SSH agent to the server. If the server already
  has its own GitHub access, leave this secret unset.

The server must be reachable by SSH from GitHub-hosted runners and have the
current Ruby version from `.ruby-version`, Node/npm for asset compilation, and
the existing Capistrano deployment prerequisites. Before the first automated
deploy, place
`/home/deploy/arxiv-reader/shared/config/database.yml` and
`/home/deploy/arxiv-reader/shared/config/master.key` on the server; do not put
production credentials in the workflow. The `deploy` user's SSH client must
also trust GitHub's SSH host key. If the server is not reachable from GitHub's
runners, use a self-hosted runner with access to it.
