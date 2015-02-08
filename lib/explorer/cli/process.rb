require 'rainbow'

module Explorer
  module CLI
    class Process < Thor
      desc 'tail', 'Tail log'
      def tail
        Celluloid.logger = nil # Silence celluloid

        ipc = IPCClient.new
        ipc.tail
      rescue Errno::ENOENT
        puts Rainbow('Explore is not running').color(:red).bright
      end

      desc 'add LABEL CMD (--dir=DIR)', 'Add command'
      option :dir
      def add(label, cmd)
        Celluloid.logger = nil # Silence celluloid

        ipc = IPCClient.new
        ipc.cmd_add(label, cmd, options[:dir])
      rescue Errno::ENOENT
        puts Rainbow('Explore is not running').color(:red).bright
      end
    end
  end
end
