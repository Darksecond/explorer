require 'pty'
require 'celluloid/io'

# TODO: Wrap slave File as well
module Celluloid
  module IO
    module PTY
      class Master < Stream
        extend Forwardable

        def_delegators :@io, :read_nonblock, :write_nonblock, :close, :close_read, :close_write, :closed?

        def initialize(io)
          super()
          @io = io
        end

        def to_io
          @io
        end
      end

      def self.open
        m,s = ::PTY.open
        cm = Master.new(m)
        yield [cm,s] if block_given?
        [cm,s]
      end
    end
  end
end
