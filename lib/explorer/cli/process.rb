module Explorer
  module CLI
    class Process < Thor
      desc 'tail', 'Tail log'
      def tail
        ipc = IPCClient.new
        ipc.tail
      end

      desc 'add LABEL CMD (--dir=DIR)', 'Add command'
      option :dir
      def add(label, cmd)
        ipc = IPCClient.new
        ipc.cmd_add(label, cmd, options[:dir])
      end
    end
  end
end
