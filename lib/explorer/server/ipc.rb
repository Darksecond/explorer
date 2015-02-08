require 'celluloid/io'
require 'json'

module Explorer
  module Server
    class IPC
      include Celluloid::IO
      finalizer :shutdown
      attr_reader :socket_path, :server

      def initialize(socket_path = '/tmp/explorer_ipc', servers)
        @socket_path = socket_path
        @server = UNIXServer.new(socket_path)
        @servers = servers
        async.run
      end

      def shutdown
        if @server
          @server.close
          File.delete @socket_path
        end
      end

      def run
        loop { async.handle_connection @server.accept }
      end

      def handle_connection(socket)
        loop do
          json = JSON.parse socket.readline
          case json['command']
          when 'map-list'
            socket.puts @servers.hostmap.to_json
          when 'map-add'
            @servers.hostmap[json['map']] = { host: json['host'], port: json['port'].to_i }
          when 'tail'
            @servers.log_watcher.add(socket)
          when 'cmd-add'
            @servers.process_manager.add(json['label'], json['cmd'], working_dir: json['dir'] || ENV['PWD'])
            @servers.process_manager.start(json['label']) #TODO Refactor out?
          end
        end
      rescue EOFError, JSON::ParserError
      ensure
        socket.close
      end
    end
  end
end
