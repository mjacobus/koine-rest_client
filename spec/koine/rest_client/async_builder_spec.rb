# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Koine::RestClient::AsyncBuilder do
  subject(:builder) { described_class.new(client, response_parser, queue) }

  let(:queue) { Koine::RestClient::AsyncQueue.new }
  let(:client) { MockClient.new }
  let(:response_parser) { instance_double(Koine::RestClient::ResponseParser) }
  let(:block) { proc { |var| "#{var}-after-block" } }

  describe '#get' do
    it 'queues a get request' do
      builder.get('foo', 'bar', &block)

      expect(queue.to_a).to eq([[{ get: %w[foo bar] }, block]])
    end
  end

  describe '#post' do
    it 'queues a post request' do
      builder.post('foo', 'bar', &block)

      expect(queue.to_a).to eq([[{ post: %w[foo bar] }, block]])
    end
  end

  describe '#put' do
    it 'queues a put request' do
      builder.put('foo', 'bar', &block)

      expect(queue.to_a).to eq([[{ put: %w[foo bar] }, block]])
    end
  end

  describe '#patch' do
    it 'queues a patch request' do
      builder.patch('foo', 'bar', &block)

      expect(queue.to_a).to eq([[{ patch: %w[foo bar] }, block]])
    end
  end

  describe '#delete' do
    it 'queues a delete request' do
      builder.delete('foo', 'bar', &block)

      expect(queue.to_a).to eq([[{ delete: %w[foo bar] }, block]])
    end
  end

  describe '#parsed_responses' do
    context 'when requests have blocks' do
      before do
        allow(response_parser).to receive(:parse) do |request, &block|
          block.call("response-for-#{request}")
        end

        queue.push('request1', &block)
        queue.push('request2', &block)
      end

      it 'returns the parsed responses' do
        expected = %w[
          response-for-requested-request1-after-block
          response-for-requested-request2-after-block
        ]
        expect(builder.parsed_responses).to eq(expected)
      end

      it 'flushes the queue' do
        builder.parsed_responses

        expect(queue.to_a).to eq([])
      end
    end

    context 'when requests have blocks' do
      before do
        allow(response_parser).to receive(:parse) do |request|
          "response-for-#{request}"
        end

        queue.push('request1', &block)
        queue.push('request2')
      end

      it 'returns the parsed responses' do
        expected = %w[
          response-for-requested-request1
          response-for-requested-request2
        ]
        expect(builder.parsed_responses).to eq(expected)
      end

      it 'flushes the queue' do
        builder.parsed_responses

        expect(queue.to_a).to eq([])
      end
    end

    context 'when an error is raised but there are no error handlers' do
      let(:error) { StandardError.new('expected error') }

      before do
        allow(response_parser).to receive(:parse).and_raise(error)

        queue.push('request1')
      end

      it 'raises error' do
        expect { builder.parsed_responses }.to raise_error(error)
      end
    end

    context 'when an error is raised and there is an error handler' do
      let(:error) { StandardError.new('expected error') }

      before do
        allow(response_parser).to receive(:parse).and_raise(error)
        builder.on_error(&:message)

        queue.push('request1')
      end

      it 'does not raise error' do
        expect(builder.parsed_responses).to eq(['expected error'])
      end
    end
  end
end
