require 'rainbow'
require 'formatador'

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

      desc 'list', 'list processes'
      def list
        Celluloid.logger = nil # Silence celluloid

        ipc = IPCClient.new
        list = ipc.cmd_list
        data = list.map do |p|
          color = if p['state'] == 'stopped'
                    'red'
                  else
                    'green'
                  end
          {
            label: "[#{color}]#{p['label']}[/]",
            command: "[#{color}]#{p['cmd']}[/]",
            'working directory' => "[#{color}]#{p['dir']}[/]",
            'PID' => "[#{color}]#{p['pid']}[/]",
            'exit code' => "[#{color}]#{p['status']}[/]",
            'status' => "[#{color}]#{p['state']}[/]",
          }
        end
        Formatador.display_compact_table(data, [:label, :command, 'PID', 'exit code', 'status', 'working directory'])
      rescue Errno::ENOENT
        puts Rainbow('Explore is not running').color(:red).bright
      end
    end
  end
end
