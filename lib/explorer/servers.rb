require 'celluloid'

module Explorer
  # TODO: Hostmap should be it's own actor; immutable; or thread-safe
  class Servers
    attr_reader :dns_port, :http_port, :https_port, :ipc_file
    attr_reader :hostmap, :process_manager

    def initialize dns_port: 23400, http_port: 23401, https_port: 23402, hostmap: {}, ipc_file: '/tmp/explorer_ipc'
      @dns_port = dns_port
      @http_port = http_port
      @https_port = https_port
      @ipc_file = ipc_file
      @hostmap = hostmap
      @process_manager = ProcessManager.new nil # TODO: Log watcher
    end

    def run
      # Setup trap
      read, write = IO.pipe
      trap(:INT) { write.puts }

      # Start servers
      run!

      IO.select([read]) # Wait for trap

      # Cleanup
      terminate
    end

    def terminate
      @group.terminate if @group
      @process_manager.terminate if @process_manager
    end

    def run!
      @group = Celluloid::SupervisionGroup.new do |group|
        group.supervise_as :dns, Server::DNS, dns_port
        group.supervise_as :http, Server::HTTP, http_port, hostmap
        group.supervise_as :https, Server::HTTPS, https_port, hostmap
        group.supervise_as :ipc, Server::IPC, ipc_file, self
      end
    end
  end
end
