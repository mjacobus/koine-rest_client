# frozen_string_literal: true

module Koine
  module RestClient
    # takes care of async requests
    class AsyncBuilder
      def initialize(client, response_parser, queue = AsyncQueue.new)
        @client = client
        @response_parser = response_parser
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
        blocks = @queue.map { |_request, block| block }
        threads = @queue.map do |request|
          Thread.new { @client.perform_request(request) }
        end
        @queue.clear
        responses = threads.map(&:value)
        parse_responses(responses, blocks)
      end

      def on_error(&block)
        @error_handler = block
      end

      private

      def parse_responses(responses, blocks)
        responses.map.with_index do |response, index|
          block = blocks[index]
          begin
            @response_parser.parse(response, &block)
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
