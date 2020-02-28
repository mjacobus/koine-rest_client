# frozen_string_literal: true

module Koine
  module RestClient
    # base class for http errors
    class Error < StandardError
      attr_reader :response

      def initialize(response)
        @response = response
      end
    end
  end
end
