require 'rainbow'
require 'formatador'

module Explorer
  module CLI
    class Proxy < Thor
      desc 'list', 'List hostmapping'
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
        Formatador.display_compact_table(data)
      rescue Errno::ENOENT
        puts Rainbow('Explore is not running').color(:red).bright
      end

      desc 'add DOMAIN HOST PORT', 'Add to mapping'
      def add(domain, host, port)
        Celluloid.logger = nil # Silence celluloid

        ipc = IPCClient.new
        ipc.hostmap_add(domain, host, port)
        puts "Added #{domain} to hostmap"
      rescue Errno::ENOENT
        puts Rainbow('Explore is not running').color(:red).bright
      end
    end
  end
end
