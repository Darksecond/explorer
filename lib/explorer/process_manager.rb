require 'dotenv'

module Explorer
  class ProcessManager
    def initialize options={}
      @log_watcher = options.fetch(:log_watcher) { Explorer.log_watcher }
      @processes = {}
    end

    def terminate
      labels.each do |label|
        remove(label)
      end
    end

    def add(label, command, working_dir: ENV['PWD'])
      env = load_env(working_dir)
      @processes[label] = Process.new(label, command, working_dir: working_dir, log_watcher: @log_watcher, env: env)
    end

    def remove(label)
      fail "Label is unknown" unless @processes[label]
      @processes[label].terminate
      @processes.delete label
    end

    def start(label)
      fail "Label is unknown" unless @processes[label]
      @processes[label].start
    end

    def stop(label)
      fail "Label is unknown" unless @processes[label]
      @processes[label].stop
    end

    def restart(label)
      stop(label)
      start(label)
    end

    def exists?(label)
      !!@processes[label]
    end

    def running?(label)
      fail "Label is unknown" unless @processes[label]
      @processes[label].started?
    end

    def processes
      @processes.values
    end

    def labels
      @processes.keys
    end

    private

    def load_env(directory = ENV['PWD'])
      path = File.expand_path File.join(directory, '.env')
      return {} unless File.exist?(path)
      Dotenv::Environment.new(path)
    end
  end
end
