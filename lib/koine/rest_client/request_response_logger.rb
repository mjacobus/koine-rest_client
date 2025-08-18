# frozen_string_literal: true

require 'logger'

module Koine
  # The gem namespace
  module RestClient
    # Log requests, responses and errors
    class RequestResponseLogger
      def initialize(logger, log_level: ::Logger::INFO)
        @logger = logger.tap do |log|
          log.progname = 'Koine::RestClient'
          log.level = log_level
        end
      end

      def log_request(request)
        @logger.info(request.debug_info)
      end

      def log_response(response)
        @logger.info("Response: #{response.code} #{response.body}")
      end

      def log_error(error)
        if error.respond_to?(:response)
          response = error.response
          if response.respond_to?(:code) && response.respond_to?(:body)
            return @logger.error("Response: #{response.code} #{error.message} - #{response.body}")
          end
        end

        @logger.error("Error: #{error.class} - #{error.message}")
      end
    end
  end
end
