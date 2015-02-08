module Explorer
  class ProcessManager
    def initialize log_watcher = nil
      @log_watcher = log_watcher
      @processes = {}
    end

    def terminate
      labels.each do |label|
        remove(label)
      end
    end

    def add(label, command, working_dir: ENV['PWD'])
      #TODO $PORT replacement? (or somewhere else, perhaps)
      @processes[label] = Process.new(label, command, working_dir: working_dir, log_watcher: @log_watcher)
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
  end
end
