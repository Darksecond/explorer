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
      parts = domain.split '.'
      map = nil
      while !parts.empty? && map.nil? do
        map = @mappings[parts.join('.')]
        parts.shift
      end
      map
    end
  end
end
