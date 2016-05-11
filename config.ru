require "bundler/setup"
require "middleman-core/load_paths"

Middleman.setup_load_paths

require "middleman-core"
require "middleman-core/preview_server"

class Middleman::PreviewServer
  def self.preview_in_rack
    @options = { latency: 0.25 }
    @cli_options = {}
    @server_information = ServerInformation.new
    @app = initialize_new_app
    ::Middleman::Rack.new(@app).to_app
  end
end

run Middleman::PreviewServer.preview_in_rack
