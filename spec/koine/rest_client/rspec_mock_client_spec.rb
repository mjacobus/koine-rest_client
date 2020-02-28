# frozen_string_literal: true

require 'spec_helper'
require 'koine/rest_client/rspec_mock_client'

RSpec.describe Koine::RestClient::RspecMockClient do
  subject(:client) { described_class.new(self) }

  describe '#mock' do
    before do
      client.mock do |mocker|
        mocker.get('foo').will_return(body: { foo: :bar })
        mocker.put('bar', baz: :foo).will_return(body: { baz: :bar })
        mocker.delete('error').will_return(code: 400, body: { message: :oops })
      end
    end

    it 'returns a get response' do
      result = client.get('foo')

      expect(result).to eq(foo: :bar)
    end

    it 'returns a batch' do
      responses = nil
      response = nil

      2.times do
        # make sure async requests won't mix with regular requests
        response = client.get('foo')

        responses = client.async do |async|
          async.get('foo')
          async.put('bar', baz: :foo)
        end
      end

      expected = [{ foo: :bar }, { baz: :bar }]

      expect(responses).to eq(expected)
      expect(response).to eq(responses[0])
    end

    it 'raises error when response is not 200' do
      expect { client.delete('error') }.to raise_error do |error|
        expect(error.response.parsed_response[:message]).to eq(:oops)
      end
    end

    it 'forwards the blocks' do
      client.mock do |mocker|
        mocker.get('bar').will_return(body: 'the-body')
      end

      value = nil

      client.get('bar') do |response|
        value = response
      end

      expect(value.parsed_response).to eq('the-body')
    end
  end

  describe '#async' do
    it 'sets an error handler' do
      client.mock do |mocker|
        mocker.get('ok1').will_return(body: 'ok1')
        mocker.get('error').will_return(code: 500, body: 'oops')
        mocker.get('ok2').will_return(body: 'ok2')
        mocker.on_error do |error|
          "error handled: #{error.response.parsed_response}"
        end
      end

      responses = client.async do |async|
        async.get('ok1')
        async.get('error')
        async.get('ok2')
      end

      expect(responses).to eq(['ok1', 'error handled: oops', 'ok2'])
    end

    it 'does not overwrite the default error handler' do
      client.mock do |mocker|
        mocker.get('error').will_return(code: 500)
        mocker.on_error do |_error|
          'error handled'
        end
      end

      expect { client.get('error') }.to raise_error(Koine::RestClient::InternalServerError)
    end
  end

  describe '#will_return' do
    it 'takes a block for configuring the response' do
      client.mock do |mocker|
        mocker.get('foo').will_return(body: 'parsed-body') do |response|
          # rubocop:disable RSpec/VerifiedDoubles
          double(code: 200, parsed_response: "the #{response.parsed_response}")
          # rubocop:enable RSpec/VerifiedDoubles
        end
      end

      expect(client.get('foo')).to eq('the parsed-body')
    end
  end
end
