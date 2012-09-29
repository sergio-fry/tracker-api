require 'eventmachine'
require 'evma_httpserver'
require 'yajl'

require 'tracker-api/router'

module TrackerApi
  class HttpServer < EM::Connection
    include EM::HttpServer

    def initialize
      @routes = {
        /^\/search\/?$/ => :_action_search
      }
    end

    def post_init
      super
      no_environment_strings
    end

    def process_http_request
      # the http request details are available via the following instance variables:
      #   @http_protocol
      #   @http_request_method
      #   @http_cookie
      #   @http_if_none_match
      #   @http_content_type
      #   @http_path_info
      #   @http_request_uri
      #   @http_query_string
      #   @http_post_content
      #   @http_headers

      @routes.each do |route, action|
        if @http_path_info.match(route)
          response = self.send(action,  Hash[URI::decode_www_form(@http_query_string)])
          break
        end
      end

      response = EM::DelegatedHttpResponse.new(self)
      response.status = 404
      response.content_type 'text/html'
      response.content = 'Not found!'
      response.send_response
    end

    private

    def _action_search(params)
      response = EM::DelegatedHttpResponse.new(self)
      response.status = 200
      response.content_type 'text/json'

      @tracker = RgFootball.new "APIMan", "lowkick"

      response.content = Yajl::Encoder.encode(@tracker.find_torrents(params["q"]))
      response.send_response
    end
  end
end
