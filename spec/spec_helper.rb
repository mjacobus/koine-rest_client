# frozen_string_literal: true

require 'simplecov'
require 'simplecov-lcov'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter.new(
  [
    SimpleCov::Formatter::HTMLFormatter,
    SimpleCov::Formatter::LcovFormatter
  ]
)

SimpleCov::Formatter::LcovFormatter.config do |c|
  c.report_with_single_file = true
  c.single_report_path = "coverage/lcov.info"
end

SimpleCov.start do
  add_filter %r{^/spec/}
end

require 'bundler/setup'
require 'koine/rest_client'
require 'object_comparator/rspec'
require 'tempfile'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  config.order = :random
  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

# rubocop:disable Metrics/AbcSize
def with_immutable(object)
  yield(object).tap do |returned|
    expect(returned).to(
      be_a(object.class),
      "#{returned.class} should have been a #{object.class}"
    )

    expect(returned).not_to(be(object), "#{object.class} should not have been muttated")
    expect(object).to be_frozen
    expect(returned).to be_frozen
  end
end
# rubocop:enable Metrics/AbcSize

class MockClient
  attr_reader :storage

  def initialize(storage = [])
    @storage = storage
  end

  def create_get_request(*args)
    { get: args }
  end

  def create_post_request(*args)
    { post: args }
  end

  def create_put_request(*args)
    { put: args }
  end

  def create_patch_request(*args)
    { patch: args }
  end

  def create_delete_request(*args)
    { delete: args }
  end

  def perform_request(request)
    "requested-#{request}"
  end
end
