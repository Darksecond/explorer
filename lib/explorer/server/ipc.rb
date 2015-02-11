require 'celluloid/io'
require 'json'

module Explorer
  module Server
    class IPC
      include Celluloid::IO
      finalizer :shutdown
      attr_reader :socket_path, :server

      def initialize(socket_path, options={})
        @socket_path = socket_path
        @server = UNIXServer.new(socket_path)
        @hostmap = options.fetch(:hostmap) { Explorer.hostmap }
        @log_watcher = options.fetch(:log_watcher) { Explorer.log_watcher }
        @process_manager = options.fetch(:process_manager) { Explorer.process_manager }
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
            socket.puts @hostmap.mappings.to_json
          when 'map-add'
            @hostmap.add json['map'], json['host'], json['port'].to_i
          when 'map-remove'
            @hostmap.remove json['map']
          when 'cmd-tail'
            @log_watcher.add(socket)
          when 'cmd-add'
            @process_manager.add(json['label'], json['cmd'], working_dir: json['dir'] || ENV['PWD'])
          when 'cmd-start'
            @process_manager.start(json['label'])
          when 'cmd-stop'
            @process_manager.stop(json['label'])
          when 'cmd-remove'
            @process_manager.remove(json['label'])
          when 'cmd-list'
            socket.puts @process_manager.processes.map { |p|
              {
                label: p.label,
                cmd: p.command,
                dir: p.working_dir,
                state: p.state,
                pid: p.pid,
                status: p.status.nil? ? nil : p.status.to_i,
              }
            }.to_json
          end
        end
      rescue EOFError, JSON::ParserError
      ensure
        socket.close
      end
    end
  end
end
