require 'explorer/version'
require 'explorer/cli'
require 'explorer/server/dns'
require 'explorer/server/http'
require 'explorer/server/https'
require 'explorer/server/ipc'
require 'explorer/servers'
require 'explorer/proxy'
require 'explorer/request_stream'
require 'explorer/ipc_client'
require 'explorer/process'
require 'explorer/process_manager'
require 'explorer/log_watcher'
require 'explorer/setup'

module Explorer
  DATADIR = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data'))

  def self.without_bundler
    if defined?(Bundler)
      Bundler.with_clean_env do
        yield
      end
    else
      yield
    end
  end
end
