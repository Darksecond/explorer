require 'thor'

module Explorer
  class CLI < Thor
    desc "version", "Print version of explorer"
    def version
      puts Explorer::VERSION
    end
    map %w(-v --version) => :version

    desc "start CONFIG", 'Start explorer'
    def start(file)
      servers = Servers.new hostmap: {'test.dev' => {host: 'localhost', port: 8080}}
      servers.run
    end

    desc 'map-list', 'List hostmapping'
    def map_list
      ipc = IPCClient.new
      map = ipc.hostmap_list
        puts "-------------------------------------------------------"
        puts "|             MAP |            HOST |            PORT |"
      map.each do |k,v|
        puts "| #{k.rjust(15)} | #{v['host'].rjust(15)} | #{v['port'].to_s.rjust(15)} |"
      end
        puts "-------------------------------------------------------"
    end

    desc 'map-add DOMAIN HOST PORT', 'Add to mapping'
    def map_add(domain, host, port)
      ipc = IPCClient.new
      ipc.hostmap_add(domain, host, port)
      puts "Added #{domain} to hostmap"
    end
  end
end
