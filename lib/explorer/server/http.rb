require 'reel'

module Explorer
  module Server
    class HTTP < Reel::Server::HTTP
      def initialize(port, options={})
        @map = options.fetch(:hostmap) { Explorer.hostmap }

        super '0.0.0.0', port, {}, &method(:on_connection)
      end

      def on_connection(connection)
        connection.each_request do |request|
          handle_request(request)
        end
      end

      def handle_request(request)
        map = @map.resolve(request.headers['Host'])
        if map
          Proxy.new(map[:host], map[:port]).handle(request)
        else
          request.respond 404, "Map not found (#{request.headers['Host']})"
        end

      end
    end
  end
end
