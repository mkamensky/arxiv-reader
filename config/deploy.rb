# config valid for current version and patch releases of Capistrano
#lock "~> 3"

set :application, "arxiv-reader"
set :repo_url, "git@github.com:mkamensky/arxiv-reader.git"

set :rbenv_type, :user
set :rbenv_ruby, `rbenv local`.chomp
#set :rbenv_prefix, "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_map_bins, %w[rake gem bundle ruby rails puma pumactl]
set :rbenv_roles, :all

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"
set :deploy_to, '/home/deploy/arxiv-reader'

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
set :pty, true

# Default value for :linked_files is []
append :linked_files, "config/database.yml", 'config/master.key', 'config/puma.rb'

namespace :deploy do
  namespace :check do
    before :linked_files, :set_master_key do
      on roles(:app) do
        # rubocop: disable Style/IfUnlessModifier
        unless test("[ -f #{shared_path}/config/master.key ]")
          upload! 'config/master.key', "#{shared_path}/config/master.key"
        end
        # rubocop: enable Style/IfUnlessModifier
      end
    end
  end
end

# Default value for linked_dirs is []
append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "public", "vendor", "storage"

append :assets_manifests, "public/vite/.vite/manifest*.*"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

set :migration_role, :app

after :deploy, 'deploy:restart'

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
set :ssh_options, {
  forward_agent: true,
  auth_methods: %w[publickey],
}

# puma
set :puma_workers, 2 # check your CPU specs
set :puma_rackup, -> { File.join(current_path, 'config.ru') }
set :puma_state, "#{shared_path}/tmp/pids/puma.state"
set :puma_pid, "#{shared_path}/tmp/pids/puma.pid"
set :puma_default_control_app, "unix://#{shared_path}/tmp/sockets/pumactl.sock"
set :puma_access_log, "#{shared_path}/log/puma_access.log"
set :puma_error_log, "#{shared_path}/log/puma_error.log"
set :puma_conf, "#{shared_path}/puma.rb"
set :puma_bind, "unix://#{shared_path}/tmp/sockets/puma.sock"
set :puma_init_active_record, true

set :puma_control_app, false
set :puma_systemctl_user, :user
set :puma_service_unit_type, 'simple' # or notify
set :puma_enable_socket_service, true # mendatory in our case
set :puma_service_unit_env_vars, %w[
  RBENV_ROOT=/home/deploy/.rbenv
  RBENV_VERSION=3.4.5
]

# nginx
set :nginx_config_name, 'arxiv-reader'
set :nginx_server_name, 'dibbler.verymad.net'
set :nginx_use_ssl, false # will be handled by certbot
