require 'rubydns'

module Explorer
  module Server
    class DNS < RubyDNS::Server
      def initialize(port = 23400)
        super listen: interfaces(port)
        run
      end

      def process(name, resource_class, transaction)
        transaction.fail!(:NXDomain) unless name_matches?(name)

        case resource_class
        when Resolv::DNS::Resource::IN::A
          transaction.respond!('127.0.0.1')
        when Resolv::DNS::Resource::IN::AAAA
          transaction.respond!('::1')
        else
          transaction.fail!(:NXDomain)
        end
      end

      private

      def interfaces(port)
        [
          [:udp, "0.0.0.0", port],
          [:tcp, "0.0.0.0", port]
        ]
      end

      def name_matches?(name)
        name =~ /.*\.dev/
      end
    end
  end
end
