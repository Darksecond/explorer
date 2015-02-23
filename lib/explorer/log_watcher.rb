require 'rainbow'

module Explorer
  class LogWatcher
    COLORS = [:red, :green, :yellow, :blue, :magenta, :cyan]
    include Celluloid

    def initialize
      @watchers = []
      @label_colors = {}
    end

    def add(watcher)
      @watchers << watcher
    end

    def remove(watcher)
      watcher.close unless watcher.closed?
      @watchers.delete watcher
    end

    def log(label, line)
      @watchers.each do |watcher|
        begin
          color = @label_colors[label] ||= next_color
          watcher.puts Rainbow(label).color(color).bright + " : " + line
        rescue => e
          remove(watcher)
        end
      end
    end

    def logger(label='system')
      @logger ||= ::Logger.new(LogDevice.new(self, label))
    end

    private

    class LogDevice
      def initialize(watcher, label='system')
        @watcher = watcher
        @label = label
      end

      def close
      end

      def write(data)
        @watcher.log(@label, data)
      end
    end

    def next_color
      color = COLORS.shift
      COLORS.push color
      color
    end
  end
end
