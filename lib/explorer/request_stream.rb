module Explorer
  class RequestStream
    attr_reader :request
    def initialize(request)
      @request = request
    end

    def readpartial(maxlen, outbuf="")
      results = request.body.readpartial(maxlen)
      if results.nil?
        outbuf.replace ""
        raise EOFError.new("End of Stream")
      else
        outbuf.replace results
      end
      outbuf
    end
  end
end
