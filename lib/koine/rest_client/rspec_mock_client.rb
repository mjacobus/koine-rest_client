# frozen_string_literal: true

module Koine
  module RestClient
    # mock client
    class RspecMockClient
      attr_reader :client_mock

      def initialize(rspec, response_parser: ResponseParser.new)
        @client_mock = rspec.instance_double(Koine::RestClient::Client)
        @builder = MockFactory.new(rspec, self)
        @collected = []
        @response_parser = response_parser
        @error_handler = proc do |error|
          raise error
        end
      end

      def on_error(&block)
        @error_handler = block
      end

      def mock
        yield(@builder)
      end

      def get(*args, &block)
        parse(@client_mock.get(*args), &block)
      end

      def post(*args, &block)
        parse(@client_mock.post(*args), &block)
      end

      def put(*args, &block)
        parse(@client_mock.put(*args), &block)
      end

      def patch(*args, &block)
        parse(@client_mock.patch(*args), &block)
      end

      def delete(*args, &block)
        parse(@client_mock.delete(*args), &block)
      end

      def async
        @async = true
        yield(self)
        @async = false

        responses = @collected.dup
        @collected.clear
        responses.map(&:parsed_response)
      end

      private

      def parse(response, &block)
        @response_parser.parse(response, &block).tap do |_parsed|
          if @async
            @collected << response
          end
        end
      rescue StandardError => exception
        unless @async
          raise exception
        end

        @collected << MockResponse.new.tap do |new_response|
          new_response.parsed_response = @error_handler.call(exception)
        end
      end
    end

    # mock response
    class MockResponse
      attr_accessor :code
      attr_accessor :parsed_response
    end

    # mock factory
    class MockFactory < SimpleDelegator
      def initialize(rspec, client_proxy)
        super(rspec)
        @client_proxy = client_proxy
      end

      def get(*args)
        create_mock(:get, *args)
      end

      def post(*args)
        create_mock(:post, *args)
      end

      def put(*args)
        create_mock(:put, *args)
      end

      def patch(*args)
        create_mock(:patch, *args)
      end

      def delete(*args)
        create_mock(:delete, *args)
      end

      def on_error(&block)
        @client_proxy.on_error(&block)
      end

      private

      def create_mock(method, *args)
        allowed = allow(@client_proxy.client_mock).to receive(method)
        MockBuilder.new(allowed).with(*args)
      end
    end

    # mock builder
    class MockBuilder
      def initialize(mock)
        @mock = mock
      end

      def with(*args)
        @mock.with(*args)
        self
      end

      def will_return(body: {}, code: 200)
        response = MockResponse.new
        response.parsed_response = body
        response.code = code
        if block_given?
          response = yield(response)
        end
        @mock.and_return(response)
        self
      end

      def on_error(&block)
        @error_handler = block
      end
    end
  end
end
