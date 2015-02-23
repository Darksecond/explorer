require 'thor'
require 'explorer/cli/proxy'
require 'explorer/cli/process'
require 'explorer/cli/setup'

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

      desc 'setup SUBCOMMAND ...ARGS', 'manage explorer setup'
      subcommand 'setup', Setup

      desc "boot", 'Start explorer'
      def boot
        servers = Servers.new
        Explorer.log_watcher.add(STDOUT)
        servers.run
      end

    end
  end
end
