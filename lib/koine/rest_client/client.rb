# frozen_string_literal: true

# :reek:DataClump
# :reek:FeatureEnvy
module Koine
  module RestClient
    class Client
      def initialize(
        adapter: Adapters::HttpPartyAdapter.new,
        response_parser: ResponseParser.new,
        base_request: Request.new
      )
        @adapter = adapter
        @response_parser = response_parser
        @request = base_request
      end

      def get(path, query = {}, options = {}, &block)
        request = create_get_request(path, query, options)
        response = perform_request(request)
        parse_response(response, &block)
      end

      def create_get_request(path, query = {}, options = {})
        create_request(:get, path, options.merge(query_params: query))
      end

      def post(path, body = {}, options = {}, &block)
        request = create_post_request(path, body, options)
        response = perform_request(request)
        parse_response(response, &block)
      end

      def create_post_request(path, body = {}, options = {})
        create_request(:post, path, options.merge(body: body))
      end

      def put(path, body = {}, options = {}, &block)
        request = create_put_request(path, body, options)
        response = perform_request(request)
        parse_response(response, &block)
      end

      def create_put_request(path, body = {}, options = {})
        create_request(:put, path, options.merge(body: body))
      end

      def patch(path, body = {}, options = {}, &block)
        request = create_patch_request(path, body, options)
        response = perform_request(request)
        parse_response(response, &block)
      end

      def create_patch_request(path, body = {}, options = {})
        create_request(:patch, path, options.merge(body: body))
      end

      def delete(path, body = {}, options = {}, &block)
        request = create_delete_request(path, body, options)
        response = perform_request(request)
        parse_response(response, &block)
      end

      def create_delete_request(path, body = {}, options = {})
        create_request(:delete, path, options.merge(body: body))
      end

      def async
        builder = AsyncBuilder.new(self, @response_parser)
        yield(builder)
        builder.parsed_responses
      end

      def perform_request(request)
        @adapter.send_request(request)
      end

      private

      def create_request(method, path, options = {})
        options = options.merge(method: method, path: path)
        @request.with_added_options(options)
      end

      def parse_response(response, &block)
        @response_parser.parse(response, &block)
      end
    end
  end
end
