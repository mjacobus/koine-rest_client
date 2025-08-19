# frozen_string_literal: true

module Koine
  module RestClient
    # takes care of async requests
    class AsyncBuilder
      def initialize(client, adapter, queue = AsyncQueue.new)
        @client = client
        @adapter = adapter
        @queue = queue
        @error_handler = proc do |error|
          raise error
        end
      end

      def get(*args, &block)
        queue(:get, *args, &block)
      end

      def post(*args, &block)
        queue(:post, *args, &block)
      end

      def put(*args, &block)
        queue(:put, *args, &block)
      end

      def patch(*args, &block)
        queue(:patch, *args, &block)
      end

      def delete(*args, &block)
        queue(:delete, *args, &block)
      end

      def parsed_responses
        threads = @queue.map do |request, block|
          Thread.new { [request, @adapter.send_request(request), block] }
        end
        @queue.clear
        responses = threads.map(&:value)
        parse_responses(responses)
      end

      def perform_requests(requests, &block)
        requests.each do |request|
          @queue.push(request, &block)
        end
      end

      def perform_request(request, &block)
        @queue.push(request, &block)
      end

      def on_error(&block)
        @error_handler = block
      end

      private

      def parse_responses(responses)
        responses.map.with_index do |(request, response, block), index|
          begin
            @adapter.parse_response(response, request:, &block)
          rescue StandardError => exception
            @error_handler.call(exception)
          end
        end
      end

      def queue(type, *args, &block)
        request = @client.__send__("create_#{type}_request", *args)
        @queue.push(request, &block)
      end
    end
  end
end
