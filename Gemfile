# frozen_string_literal: true

source 'https://rubygems.org'
git_source(:github) { "https://github.com/#{it}.git" }

ruby '>=3.4'

# Bundle edge Rails instead: gem 'rails', github: 'rails/rails', branch: 'main'
gem 'rails', '>=8'

gem 'pg'

gem 'pg_search'

gem 'migration_data'

gem 'paper_trail'

#gem 'active_record_extended'

gem 'latex-decode'

# Use Active Model has_secure_password
# [https://guides.rubyonrails.org/active_model_basics.html#securepassword]
gem 'bcrypt', '>=3.1.7'

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

# Use Active Storage variants [https://guides.rubyonrails.org/active_storage_overview.html#transforming-images]
# gem 'image_processing', '~> 1.2'

# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>=6.0'

group :development, :test do
  gem 'js_from_routes'

  # See https://guides.rubyonrails.org/debugging_rails_applications.html#debugging-with-the-debug-gem
  gem 'debug', platforms: %i[mri]

  # Automatic Ruby code style checking tool.
  # (https://github.com/rubocop/rubocop)
  gem 'rubocop', require: false

  # Automatic performance checking tool for Ruby code. (https://github.com/rubocop/rubocop-performance)
  gem 'rubocop-performance', require: false

  # Automatic Rails code style checking tool. (https://github.com/rubocop/rubocop-rails)
  gem 'rubocop-rails', require: false
  gem 'rubocop-faker', require: false

  # factory_bot_rails provides integration between factory_bot and rails 5.0 or newer (https://github.com/thoughtbot/factory_bot_rails)
  gem 'factory_bot_rails'

  gem 'rspec-rails'
end

group :development do
  # Use console on exceptions pages [https://github.com/rails/web-console]
  gem 'web-console'

  # Add speed badges [https://github.com/MiniProfiler/rack-mini-profiler]
  gem 'rack-mini-profiler'

  # Speed up commands on slow machines / big apps [https://github.com/rails/spring]
  gem 'spring'

  gem 'amazing_print'

  gem "capistrano", require: false
  gem 'capistrano3-puma', '>= 6.2', require: false
  gem "capistrano-rails", require: false
  gem 'capistrano-bundler', require: false
  gem 'capistrano-rbenv', '~> 2.0', require: false
  gem 'capistrano-rbenv-install', require: false
  gem 'ed25519', require: false
  gem 'bcrypt_pbkdf', require: false
  gem 'database_consistency', require: false
end

group :test do
  # Use system testing [https://guides.rubyonrails.org/testing.html#system-testing]
  gem 'capybara'
  gem 'selenium-webdriver', '>=4.11'
  #gem 'webdrivers'
  gem 'faker'
end

gem 'inertia_rails', '>=3.0'

gem 'vite_rails', '>=3.0'

#gem 'sqlite3', require: false # to interface with asl

# fast json
gem 'oj'

gem 'friendly_id'
gem 'faraday', require: false
gem 'faraday-retry', require: false
gem 'faraday-follow_redirects', require: false
gem 'feedjira', require: false
gem 'oai', require: false
gem 'libxml-ruby', require: false
gem 'omniauth', '>=2.1.4'
gem "omniauth-rails_csrf_protection"
gem 'omniauth-github'
gem 'omniauth-orcid'
gem 'omniauth-google-oauth2'

group :production do
  gem 'sd_notify'
  gem 'solid_errors'
end

gem 'meta_request'
gem "pundit"
