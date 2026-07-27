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


