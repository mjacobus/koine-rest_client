# frozen_string_literal: true

require 'addressable'

module Koine
  # Url builder
  class Url
    # Exception for when the argument is invalid
    ArgumentError = Class.new(::ArgumentError)

    def initialize(url)
      @url = validate(url).to_s.freeze
      freeze
    end

    # :reek:UncommunicativeVariableName
    # :reek:DuplicateMethodCall
    def with_query_params(params)
      if params.empty?
        return self.class.new(to_s.split('?').first)
      end

      url = parsed.tap do |p|
        p.query_values = params
      end

      self.class.new(url.to_s)
    end

    def with_query_param(param_name, value)
      with_query_params(query_params.merge(param_name.to_s => value))
    end

    def query_params
      parsed.query_values || {}
    end

    def uri
      parsed.request_uri
    end

    def to_s(unescape: nil)
      unless unescape
        return @url
      end

      url = @url.to_s.dup

      unescape.to_s.each_char do |char|
        url = url.gsub(CGI.escape(char), char)
      end

      url
    end

    def ==(other)
      other.class == self.class && other.to_s == to_s
    end

    private

    def parsed(url = nil)
      url ||= to_s
      Addressable::URI.parse(url.to_s)
    end

    # :reek:TooManyStatements
    def validate(input_url)
      parsed(input_url).tap do |url|
        url.send(:validate)

        unless url.scheme
          reject(url)
        end
      end
    rescue StandardError => _exception
      reject(input_url)
    end

    def reject(url)
      raise ArgumentError, "Invalid url '#{url}'"
    end
  end
end
