require 'net/http'

module Explorer
  class Proxy
    def initialize(host, port)
      @host = host
      @port = port
    end

    def handle(reel_request)
      Net::HTTP.new(@host, @port).start do |http|
        http.request(net_request(reel_request)) do |net_response|
          # Map the headers to be friendly to reel (no arrays in values)
          headers = Hash[net_response.to_hash.map{|k,v| [k,v.join(", ")]}]
          # Delete the connection header as otherwise there will be 2
          headers.delete 'connection'
          if headers['transfer-encoding'] == 'chunked'
            reel_request.respond net_response.code.to_i, headers
            net_response.read_body do |chunk|
              reel_request << chunk
            end
            reel_request.finish_response
          else
            reel_request.respond net_response.code.to_i, headers, net_response.read_body
          end
        end
      end
    rescue Errno::ECONNREFUSED
      reel_request.respond 504, 'Could not connect to upstream server'
    end

    private

    def net_request(request)
      req = Net::HTTPGenericRequest.new(request.method, true, true, request.url, request.headers)
      # Only stream a body if there is a body attached
      # A request that has a body _must_ have either Content-Length or Transfer-Encoding
      if request.headers['content-length'] || request.headers['transfer-encoding']
        req.body_stream = RequestStream.new(request)
      end
      req
    end
  end
end
