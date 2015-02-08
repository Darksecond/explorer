module Explorer
  module CLI
    class Proxy < Thor
      desc 'list', 'List hostmapping'
      def list
        ipc = IPCClient.new
        map = ipc.hostmap_list
          puts "-------------------------------------------------------"
          puts "|             MAP |            HOST |            PORT |"
        map.each do |k,v|
          puts "| #{k.rjust(15)} | #{v['host'].rjust(15)} | #{v['port'].to_s.rjust(15)} |"
        end
          puts "-------------------------------------------------------"
      end

      desc 'add DOMAIN HOST PORT', 'Add to mapping'
      def add(domain, host, port)
        ipc = IPCClient.new
        ipc.hostmap_add(domain, host, port)
        puts "Added #{domain} to hostmap"
      end
    end
  end
end
