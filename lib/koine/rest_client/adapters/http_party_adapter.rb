# frozen_string_literal: true

require 'httparty'

module Koine
  module RestClient
    module Adapters
      # adapter for HTTParty client
      class HttpPartyAdapter
        def initialize(http_party_client = HTTParty)
          @client = http_party_client
        end

        def send_request(request)
          send("send_#{request.method}", request)
        end

        private

        def send_post(request)
          @client.post(request.url, request.options)
        end

        def send_get(request)
          @client.get(request.url, request.options)
        end

        def send_put(request)
          @client.put(request.url, request.options)
        end

        def send_patch(request)
          @client.patch(request.url, request.options)
        end

        def send_delete(request)
          @client.delete(request.url, request.options)
        end
      end
    end
  end
end
