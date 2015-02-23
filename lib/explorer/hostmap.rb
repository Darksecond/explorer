require 'yaml'

module Explorer
  class Hostmap
    include Celluloid

    attr_reader :mappings

    def initialize
      @mappings = {}
    end

    def add domain, host, port
      @mappings[domain] = { host: host, port: port }
    end

    def remove domain
      @mappings.delete domain
    end

    def resolve domain
      domain = domain.gsub(/\d+.\d+.\d+.\d+.xip.io/, 'dev') #Support xip.io
      parts = domain.split '.'
      map = nil
      while !parts.empty? && map.nil? do
        map = @mappings[parts.join('.')]
        parts.shift
      end
      map
    end

    def save file
      Dir.mkdir File.dirname(file) unless Dir.exist?(File.dirname(file))
      File.write file, YAML.dump(mappings)
    end

    def load file
      return unless File.exist? file

      yaml = YAML.load_file file
      @mappings = yaml
    end
  end
end
