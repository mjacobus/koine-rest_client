# frozen_string_literal: true

module Koine
  module RestClient
    # either returns response or raises errors
    class ResponseParser
      def parse(response, request:)
        if block_given?
          yield(response)
        end

        code = Integer(response.code)

        if code.between?(200, 299)
          if request.respond_to?(:on_success)
            request.on_success(response)
          end

          return response.parsed_response
        end

        error = error_for_code(code).new(response)

        if request.respond_to?(:on_error)
          return request.on_error(error)
        end

        raise error
      end

      private

      def error_for_code(code)
        {
          400 => BadRequestError,
          401 => UnauthorizedError,
          402 => PaymentRequiredExperimentalError,
          403 => ForbiddenError,
          404 => NotFoundError,
          405 => MethodNotAllowedError,
          406 => NotAcceptableError,
          407 => ProxyAuthenticationRequiredError,
          408 => RequestTimeoutError,
          409 => ConflictError,
          410 => GoneError,
          411 => LengthRequiredError,
          412 => PreconditionFailedError,
          413 => PayloadTooLargeError,
          414 => URITooLongError,
          415 => UnsupportedMediaTypeError,
          416 => RangeNotSatisfiableError,
          417 => ExpectationFailedError,
          418 => ImATeapotError,
          421 => MisdirectedRequestError,
          422 => UnprocessableEntityError,
          423 => LockedError,
          424 => FailedDependencyError,
          425 => TooEarlyExperimentalError,
          426 => UpgradeRequiredError,
          428 => PreconditionRequiredError,
          429 => TooManyRequestsError,
          431 => RequestHeaderFieldsTooLargeError,
          451 => UnavailableForLegalReasonsError,
          500 => InternalServerError,
          501 => NotImplementedError,
          502 => BadGatewayError,
          503 => ServiceUnavailableError,
          504 => GatewayTimeoutError,
          505 => HTTPVersionNotSupportedError,
          506 => VariantAlsoNegotiatesError,
          507 => InsufficientStorageError,
          508 => LoopDetectedError,
          510 => NotExtendedError,
          511 => NetworkAuthenticationRequiredError
        }.fetch(code) { Error }
      end
    end
  end
end
