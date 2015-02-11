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
require 'explorer/hostmap'
require 'explorer/setup'

module Explorer
  DATADIR = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data'))

  def self.hostmap
    @hostmap ||= Hostmap.new
  end

  def self.process_manager
    @process_manager ||= ProcessManager.new
  end

  def self.log_watcher
    @log_watcher ||= LogWatcher.new
  end

  def self.terminate
    @hostmap.terminate if @hostmap
    @log_watcher.terminate if @log_watcher
    @process_manager.terminate if @process_manager
  end

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
