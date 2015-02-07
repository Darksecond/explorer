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
  end
end
