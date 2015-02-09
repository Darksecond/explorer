require 'thor'
require 'rainbow'

module Explorer
  module CLI
    class Setup < Thor
      desc 'install', 'install explorer so that it can be used with `.dev` domains'
      def install
        setup = Explorer::Setup.new
        return puts Rainbow('Explorer is already installed').color(:red) if setup.installed?
        return puts Rainbow('Cannot install, not suitable').color(:red) unless setup.suitable?
        setup.install
        puts Rainbow('Done installing `.dev` support').color(:green).bright
      end

      desc 'uninstall', 'uninstall `.dev` domain support'
      def uninstall
        setup = Explorer::Setup.new
        return puts Rainbow('Explorer is not installed').color(:red) unless setup.installed?
        return puts Rainbow('Cannot uninstall, not suitable').color(:red) unless setup.suitable?
        setup.uninstall
        puts Rainbow('Done uninstalling `.dev` support').color(:green).bright
      end
    end
  end
end
