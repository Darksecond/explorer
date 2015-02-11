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
      @watcher.close
      @watchers.delete watcher
    end

    def log(label, line)
      @watchers.each do |watcher|
        begin
          color = @label_colors[label] ||= next_color
          watcher.puts Rainbow(label).color(color).bright + " : " + line
        rescue
          remove(watcher)
        end
      end
    end
  end

  private

  def next_color
    color = COLORS.shift
    COLORS.push color
    color
  end
end
