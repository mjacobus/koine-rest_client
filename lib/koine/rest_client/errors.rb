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

    # 400
    BadRequestError = Class.new(Error)
    NotFoundError = Class.new(Error)
    UnauthorizedError = Class.new(Error)
    PaymentRequiredExperimentalError = Class.new(Error)
    ForbiddenError = Class.new(Error)
    MethodNotAllowedError = Class.new(Error)
    NotAcceptableError = Class.new(Error)
    ProxyAuthenticationRequiredError = Class.new(Error)
    RequestTimeoutError = Class.new(Error)
    ConflictError = Class.new(Error)
    GoneError = Class.new(Error)
    LengthRequiredError = Class.new(Error)
    PreconditionFailedError = Class.new(Error)
    PayloadTooLargeError = Class.new(Error)
    URITooLongError = Class.new(Error)
    UnsupportedMediaTypeError = Class.new(Error)
    RangeNotSatisfiableError = Class.new(Error)
    ExpectationFailedError = Class.new(Error)
    ImATeapotError = Class.new(Error)

    # 500
    InternalServerError = Class.new(Error)
    NotImplementedError = Class.new(Error)
    BadGatewayError = Class.new(Error)
    ServiceUnavailableError = Class.new(Error)
    GatewayTimeoutError = Class.new(Error)
    HTTPVersionNotSupportedError = Class.new(Error)
    VariantAlsoNegotiatesError = Class.new(Error)
    InsufficientStorageError = Class.new(Error)
    LoopDetectedError = Class.new(Error)
    NotExtendedError = Class.new(Error)
    NetworkAuthenticationRequiredError = Class.new(Error)
  end
end
