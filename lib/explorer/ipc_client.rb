require 'celluloid/io'
require 'json'

module Explorer
  class IPCClient
    include Celluloid::IO
    finalizer :shutdown

    def initialize(socket_path = '/tmp/explorer_ipc')
      @socket_path = socket_path
      @socket = UNIXSocket.open(socket_path)
    end

    def hostmap_list
      msg = {
        command: 'map-list'
      }
      @socket.puts msg.to_json
      JSON.parse @socket.readline
    end

    def hostmap_add map, host, port
      msg = {
        command: 'map-add',
        map: map,
        host: host,
        port: port
      }
      @socket.puts msg.to_json
    end

    def tail(io = STDOUT)
      msg = {
        command: 'tail'
      }
      @socket.puts msg.to_json

      loop do
        line = @socket.readline
        io.puts line
      end
    end

    def cmd_add(label, cmd, dir=nil)
      msg = {
        command: 'cmd-add',
        label: label,
        cmd: cmd,
        dir: dir,
      }
      @socket.puts msg.to_json
    end

    def shutdown
      @socket.close if @socket
    end
  end
end
