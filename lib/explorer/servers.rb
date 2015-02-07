require 'celluloid'

module Explorer
  class Servers
    attr_reader :dns_port, :http_port, :https_port
    attr_reader :hostmap

    def initialize dns_port: 23400, http_port: 23401, https_port: 23402, hostmap: {}
      @dns_port = dns_port
      @http_port = http_port
      @https_port = https_port
      @hostmap = hostmap
    end

    def run
      run!
      sleep
    end

    def run!
      @group = Celluloid::SupervisionGroup.new do |group|
        group.supervise_as :dns, Server::DNS, dns_port
        group.supervise_as :http, Server::HTTP, http_port, hostmap
        group.supervise_as :https, Server::HTTPS, https_port, hostmap
      end
    end
  end
end
