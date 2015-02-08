require 'celluloid/io/pty'
module Explorer
  class Process
    include Celluloid::IO
    finalizer :shutdown

    attr_reader :label, :command, :working_dir, :state, :status
    attr_reader :pid, :pgid, :pipe

    def initialize(label, command, working_dir: ENV['PWD'])
      @label = label
      @command = command
      @working_dir = working_dir
      @state = :stopped
      @status = nil
    end

    def start
      return Actor.current if @state == :started

      @status = nil
      @pipe, slave = PTY.open
      slave.raw!
      @pid = spawn_process(label, command, working_dir: working_dir, pipe: slave)
      @pgid = ::Process.getpgid(@pid)
      slave.close

      @state = :started
      signal :state_changed

      wait_pid
      async.read_pipe

      return Actor.current
    end

    def stop(sig='INT')
      return Actor.current if @state == :stopped
      begin
        ::Process.kill(sig, -pgid)
        wait_on_stop
      rescue
      end
      return Actor.current
    end

    def wait_on_stop
      while @state != :stopped
        wait :state_changed
      end
      return Actor.current
    end

    private

    # TODO: Log output to a logger or something given to this actor
    def read_pipe
      loop do
        puts @pipe.readline
      end
    rescue
    end

    def wait_pid
      actor = Actor.current
      Thread.new do
        ::Process.wait(pid)
        actor.send(:wait_pid_done, $?) #Run in actor thread
      end
    end

    def wait_pid_done(status)
      @status = status
      @pid = nil
      @pgid = nil
      @state = :stopped
      signal :state_changed

      Logger.info "Process #{label} exited with #{status}"
    end

    def shutdown
      stop if @state == :started
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
