module Explorer
  class LogWatcher
    def initialize
      @watchers = []
      @mutex = Mutex.new
    end

    # TODO: terminate

    def add(watcher)
      @mutex.synchronize do
        @watchers << watcher
      end
    end

    def remove(watcher)
      @mutex.synchronize do
        @watcher.close
        @watchers.delete watcher
      end
    end

    def log(label, line)
      @mutex.synchronize do
        @watchers.each do |watcher|
          begin
            watcher.puts "#{label}: #{line}"
          rescue
            remove(watcher)
          end
        end
      end
    end
  end
end
