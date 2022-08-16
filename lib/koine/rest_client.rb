# frozen_string_literal: true

require 'httparty'
require 'koine/url'
require 'koine/rest_client/error'
require 'koine/rest_client/version'
require 'koine/rest_client/client'
require 'koine/rest_client/async_builder'
require 'koine/rest_client/async_queue'
require 'koine/rest_client/response_parser'
require 'koine/rest_client/bad_request_error'
require 'koine/rest_client/not_found_error'
require 'koine/rest_client/unauthorized_error'
require 'koine/rest_client/internal_server_error'
require 'koine/rest_client/request'
require 'koine/rest_client/adapters/http_party_adapter'

module Koine
  # The gem namespace
  module RestClient
  end
end
