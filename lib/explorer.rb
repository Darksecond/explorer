require 'explorer/version'
require 'explorer/cli'
require 'explorer/server/dns'
require 'explorer/server/http'
require 'explorer/server/https'
require 'explorer/server/ipc'
require 'explorer/servers'
require 'explorer/proxy'
require 'explorer/request_stream'
require 'explorer/ipc_client'

module Explorer
  DATADIR = File.expand_path(File.join(File.dirname(__FILE__), '..', 'data'))
end
