require 'rainbow'
require 'formatador'
require 'thor'

module Explorer
  module CLI
    class Proxy < Thor
      desc 'list', 'List proxy map'
      def list
        Celluloid.logger = nil # Silence celluloid

        ipc = IPCClient.new
        data = ipc.hostmap_list.map do |k, v|
          {
            domain: "[yellow]#{k}[/]",
            host: "[yellow]#{v['host']}[/]",
            port: "[yellow]#{v['port']}[/]",
          }
        end
        Formatador.display_compact_table(data, [:domain, :host, :port])
      rescue Errno::ENOENT
        puts Rainbow('Explore is not running').color(:red).bright
      end

      desc 'add DOMAIN HOST PORT', 'Add domain to proxy'
      def add(domain, host, port)
        Celluloid.logger = nil # Silence celluloid

        ipc = IPCClient.new
        ipc.hostmap_add(domain, host, port)
        puts "Added #{domain} to proxy"
      rescue Errno::ENOENT
        puts Rainbow('Explore is not running').color(:red).bright
      end

      desc 'remove DOMAIN', 'remove domain from proxy'
      def remove(domain)
        Celluloid.logger = nil # Silence celluloid

        ipc = IPCClient.new
        ipc.hostmap_remove(domain)
        puts "Removed #{domain} from proxy"
      rescue Errno::ENOENT
        puts Rainbow('Explore is not running').color(:red).bright
      end
    end
  end
end
