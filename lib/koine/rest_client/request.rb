# frozen_string_literal: true

module Koine
  module RestClient
    # request object
    # :reek:TooManyInstanceVariables
    class Request
      attr_reader :method
      attr_reader :base_url
      attr_reader :path
      attr_reader :headers
      attr_reader :query_params
      attr_reader :body

      def initialize(base_url: '', query_params: {}, path: '', headers: {}, method: 'get')
        @method = method
        @base_url = base_url
        @path = path
        @query_params = query_params
        @headers = headers
      end

      def with_method(method)
        new(:method, method)
      end

      def with_path(path)
        new(:path, path)
      end

      def with_base_url(base_url)
        new(:base_url, base_url)
      end

      def with_added_query_params(query_params)
        new(:query_params, @query_params.merge(query_params).compact)
      end

      def with_added_headers(headers)
        new(:headers, @headers.merge(headers).compact)
      end

      def with_body(body)
        new(:body, body)
      end

      def url
        url = "#{@base_url.delete_suffix('/')}/#{path.delete_prefix('/')}"
        Url.new(url).with_query_params(query_params).to_s(unescape: ',')
      end

      def options
        { body: body, headers: headers }.compact.reject do |_key, value|
          value.empty?
        end
      end

      # :reek:ManualDispatch
      def with_added_options(options)
        object = self
        options.each do |key, value|
          if respond_to?("with_#{key}")
            object = object.send("with_#{key}", value)
          end

          if respond_to?("with_added_#{key}")
            object = object.send("with_added_#{key}", value)
          end
        end
        object
      end

      private

      attr_writer :method
      attr_writer :base_url
      attr_writer :path
      attr_writer :query_params
      attr_writer :headers

      # :reek:FeatureEnvy
      def new(attribute, value)
        dup.tap do |object|
          object.send("#{attribute}=", value)
          object.freeze
        end
      end

      def body=(body)
        if json_request? && body.is_a?(Hash)
          body = JSON.dump(body)
        end

        @body = body
      end

      # rubocop:disable Performance/Casecmp
      def json_request?
        headers.find do |key, value|
          key.downcase == 'content-type' && value.downcase.match('application/json')
        end
      end
      # rubocop:enable Performance/Casecmp
    end
  end
end
