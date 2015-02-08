require 'thor'
require 'explorer/cli/proxy'
require 'explorer/cli/process'

module Explorer
  module CLI
    # TODO: Rename
    class CLI < Thor
      desc "version", "Print version of explorer"
      def version
        puts Explorer::VERSION
      end
      map %w(-v --version) => :version

      desc 'proxy SUBCOMMAND ...ARGS', 'manage proxy'
      subcommand 'proxy', Proxy

      desc 'process SUBCOMMAND ...ARGS', 'manage processes'
      subcommand 'process', Process

      desc "boot [CONFIG]", 'Start explorer'
      def boot(config=nil)
        servers = Servers.new hostmap: {'test.dev' => {host: 'localhost', port: 8080}}
        servers.log_watcher.add(STDOUT)
        servers.run
      end

    end
  end
end
