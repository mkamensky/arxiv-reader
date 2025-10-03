# frozen_string_literal: true

# https://inertia-rails.dev/guide/configuration

# rubocop: disable Style/ItBlockParameter
InertiaRails.configure do |config|
  config.deep_merge_shared_data = true
  config.encrypt_history = false
  # set the current version for automatic asset refreshing. A string value
  # should be used if any.
  config.version = -> { ViteRuby.digest }
  # enable default inertia rendering (warning! this will override rails default rendering behavior)
  config.default_render = true

  # ssr specific options
  config.ssr_enabled = false
  config.ssr_url = 'http://localhost:13714'
  config.always_include_errors_hash = true
end
# rubocop: enable Style/ItBlockParameter
