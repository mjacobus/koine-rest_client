# frozen_string_literal: true

require 'httparty'

module Koine
  module RestClient
    module Adapters
      # adapter for HTTParty client
      class HttpPartyAdapter
        def initialize(http_party_client = HTTParty, response_parser: ResponseParser.new)
          @client = http_party_client
          @response_parser = response_parser
        end

        def send_request(request)
          send("send_#{request.method}", request)
        end

        def parse_response(response, request:, &block)
          @response_parser.parse(response, request: request, &block)
        end

        private

        def send_post(request)
          @client.post(request.url, options_for(request))
        end

        def send_get(request)
          @client.get(request.url, options_for(request))
        end

        def send_put(request)
          @client.put(request.url, options_for(request))
        end

        def send_patch(request)
          @client.patch(request.url, options_for(request))
        end

        def send_delete(request)
          @client.delete(request.url, options_for(request))
        end

        def options_for(request)
          { body: request.body, headers: request.headers }.compact.reject do |_key, value|
            value.empty?
          end
        end
      end
    end
  end
end
