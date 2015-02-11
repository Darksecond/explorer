require 'celluloid'

module Explorer
  class Servers
    def initialize options={}
      @dns_port = options.fetch(:dns_port) { 23400 }
      @http_port = options.fetch(:http_port) { 23401 }
      @https_port = options.fetch(:https_port) { 23402 }
      @ipc_file = options.fetch(:ipc_file) { '/tmp/explorer_ipc' }
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

    # Do I need this?
    def terminate
      @group.terminate if @group
      Explorer.terminate
    end

    def run!
      @group = Celluloid::SupervisionGroup.new do |group|
        group.supervise_as :dns, Server::DNS, @dns_port
        group.supervise_as :http, Server::HTTP, @http_port
        group.supervise_as :https, Server::HTTPS, @https_port
        group.supervise_as :ipc, Server::IPC, @ipc_file
      end
    end
  end
end
