require 'celluloid/io/pty'

module Explorer
  #TODO PTY & Readers
  class ProcessManager
    include Celluloid::IO

    class Process
      include Celluloid::IO
      finalizer :shutdown

      attr_reader :pid, :label, :pgid, :pipe
      def initialize pid, label, pipe
        @pipe = pipe
        @pid = pid
        @label = label
        @pgid = ::Process.getpgid(pid)
        async.read_log
      end

      def read_log
        loop do
          line = pipe.readline
          puts "Line: #{line}"
        end
      end

      def shutdown
        pipe.close
      end
    end

    def initialize
      @processes = {}
    end

    def start(label, command, working_dir: ENV['PWD'])
      return @processes[label] if @processes[label]

      master, slave = PTY.open
      slave.raw!

      pid = spawn_process(label, command, working_dir: working_dir, pipe: slave)
      slave.close

      @processes[label] = Process.new(pid, label, master)
      wait_pid(label, pid)
      @processes[label]
    end

    def stop(label, signal = 'INT')
      process = @processes[label]
      return false unless process
      Logger.info "Stopping #{label} with signal #{signal}"

      # Kill all processes in group
      ::Process.kill(signal, -process.pgid)

      cleanup_pid(label)
    end

    def running?(label)
      !!@processes[label]
    end

    def list
      @processes.values
    end

    private

    def wait_pid(label, pid)
      Thread.new do
        ::Process.wait(pid)
        Logger.info "Process #{label} exited with status #{$?}"
        cleanup_pid(label)
      end
    end

    def cleanup_pid(label)
      @processes[label].terminate
      @processes.delete label
    end

    def spawn_process(label, command, working_dir: ENV['PWD'], pipe: :out)
      env = {}
      options = {
        chdir: working_dir,
        in: :close,
        out: pipe,
        err: pipe,
        pgroup: true,
        close_others: true,
      }
      Explorer.without_bundler do
        spawn(env, command, options)
      end
    end
  end
end
