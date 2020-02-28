# frozen_string_literal: true

module Koine
  module RestClient
    # either returns response or raises errors
    class ResponseParser
      def parse(response)
        if block_given?
          yield(response)
        end

        code = Integer(response.code)

        if code.between?(200, 299)
          return response.parsed_response
        end

        raise error_for_code(code), response
      end

      private

      def error_for_code(code)
        {
          400 => BadRequestError,
          404 => NotFoundError,
          500 => InternalServerError
        }.fetch(code) { Error }
      end
    end
  end
end
