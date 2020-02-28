# frozen_string_literal: true

RSpec.describe Koine::RestClient::Client do
  subject(:client) do
    described_class.new(
      adapter: adapter,
      response_parser: response_parser,
      base_request: request
    )
  end

  let(:request) { instance_double(Koine::RestClient::Request) }
  let(:response_parser) { instance_double(Koine::RestClient::ResponseParser) }
  let(:response) { instance_double(HTTParty::Response, parsed_response: parsed_response) }
  let(:parsed_response) { 'the-response' }
  let(:adapter) { instance_double(Koine::RestClient::Adapters::HttpPartyAdapter) }

  before do
    allow(request).to receive(:with_added_options).and_return(request)
    allow(adapter).to receive(:send_request).and_return(response)
    allow(response_parser).to receive(:parse).with(response).and_return(parsed_response)
  end

  describe '#get' do
    let(:result) { client.get('/path', { ids: '1,2,3' }, options: 'the-options') }

    it 'performs a request' do
      expect(result).to eq('the-response')
      expect(adapter).to have_received(:send_request).with(request)
      expect(request).to have_received(:with_added_options).with(
        method: :get,
        path: '/path',
        query_params: { ids: '1,2,3' },
        options: 'the-options'
      )
    end

    context 'when block given' do
      before do
        allow(response_parser).to receive(:parse).and_yield('yield-value')
      end

      it 'forwards block to response parser' do
        storage = []

        client.get('foo') do |response|
          storage << response
        end

        expect(storage).to eq(['yield-value'])
      end
    end
  end

  describe '#post' do
    let(:result) { client.post('/path', 'post-params', options: 'the-options') }

    it 'performs a request' do
      expect(result).to eq('the-response')
      expect(adapter).to have_received(:send_request).with(request)
      expect(request).to have_received(:with_added_options).with(
        method: :post,
        path: '/path',
        body: 'post-params',
        options: 'the-options'
      )
    end

    context 'when block given' do
      before do
        allow(response_parser).to receive(:parse).and_yield('yield-value')
      end

      it 'forwards block to response parser' do
        storage = []

        client.post('foo') do |response|
          storage << response
        end

        expect(storage).to eq(['yield-value'])
      end
    end
  end

  describe '#put' do
    let(:result) { client.put('/path', 'post-params', options: 'the-options') }

    it 'performs a request' do
      expect(result).to eq('the-response')
      expect(adapter).to have_received(:send_request).with(request)
      expect(request).to have_received(:with_added_options).with(
        method: :put,
        path: '/path',
        body: 'post-params',
        options: 'the-options'
      )
    end

    context 'when block given' do
      before do
        allow(response_parser).to receive(:parse).and_yield('yield-value')
      end

      it 'forwards block to response parser' do
        storage = []

        client.put('foo') do |response|
          storage << response
        end

        expect(storage).to eq(['yield-value'])
      end
    end
  end

  describe '#patch' do
    let(:result) { client.patch('/path', 'post-params', options: 'the-options') }

    it 'performs a request' do
      expect(result).to eq('the-response')
      expect(adapter).to have_received(:send_request).with(request)
      expect(request).to have_received(:with_added_options).with(
        method: :patch,
        path: '/path',
        body: 'post-params',
        options: 'the-options'
      )
    end

    context 'when block given' do
      before do
        allow(response_parser).to receive(:parse).and_yield('yield-value')
      end

      it 'forwards block to response parser' do
        storage = []

        client.patch('foo') do |response|
          storage << response
        end

        expect(storage).to eq(['yield-value'])
      end
    end
  end

  describe '#delete' do
    let(:result) { client.delete('/path', 'post-params', options: 'the-options') }

    it 'performs a request' do
      expect(result).to eq('the-response')
      expect(adapter).to have_received(:send_request).with(request)
      expect(request).to have_received(:with_added_options).with(
        method: :delete,
        path: '/path',
        body: 'post-params',
        options: 'the-options'
      )
    end

    context 'when block given' do
      before do
        allow(response_parser).to receive(:parse).and_yield('yield-value')
      end

      it 'forwards block to response parser' do
        storage = []

        client.delete('foo') do |response|
          storage << response
        end

        expect(storage).to eq(['yield-value'])
      end
    end
  end

  describe '#async' do
    let(:builder) { instance_double(Koine::RestClient::AsyncBuilder) }
    let(:responses) do
      client.async do |async|
        async.get('foo')
      end
    end

    before do
      allow(Koine::RestClient::AsyncBuilder)
        .to receive(:new)
        .with(client, response_parser).and_return(builder)

      allow(builder).to receive(:parsed_responses).and_return('responses')
      allow(builder).to receive(:get)
    end

    it 'returns parsed responses' do
      expect(responses).to eq('responses')
    end

    it 'yields builder' do
      responses

      expect(builder).to have_received(:get).with('foo')
    end
  end
end
