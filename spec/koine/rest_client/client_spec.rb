# frozen_string_literal: true

RSpec.describe Koine::RestClient::Client do
  subject(:client) do
    described_class.new(
      adapter: adapter,
      response_parser: response_parser,
      base_request: request
    )
  end

  let(:request) { instance_double(Koine::RestClient::Request, debug_info: { request: :info }) }
  let(:response_parser) { instance_double(Koine::RestClient::ResponseParser) }
  let(:response) do
    instance_double(HTTParty::Response, parsed_response: parsed_response, code: 200,
      body: 'the-body')
  end
  let(:parsed_response) { 'the-response' }
  let(:adapter) { instance_double(Koine::RestClient::Adapters::HttpPartyAdapter) }

  before do
    allow(request).to receive(:with_added_options).and_return(request)
    allow(adapter).to receive(:send_request).and_return(response)
    allow(response_parser).to receive(:parse).with(response, request: request).and_return(parsed_response)
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

    context "with vcr" do
      let(:base_request) { Koine::RestClient::Request.new(base_url: 'https://api.github.com') }
      let(:client) { Koine::RestClient::Client.new(base_request: base_request) }

      it "makes requests" do
        VCR.use_cassette('koine_rest_client_client_get') do
          response = client.get('/users/mjacobus')
          expect(response['login']).to eq('mjacobus')
        end
      end

      it "takes a block" do
        VCR.use_cassette('koine_rest_client_client_get') do
          client.get('/users/mjacobus') do |response|
            expect(response['login']).to eq('mjacobus')
          end
        end
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
    context "mokies AsyncBuilder" do
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

    context 'with integration' do
      let(:client) { Koine::RestClient::Client.new }

      it 'queues requests' do
        VCR.use_cassette('koine_rest_client_client_async') do
          responses = client.async do |async|
            async.perform_request(GithubUserRequest.new('mjacobus'))
            async.perform_request(GithubUserRequest.new('dhh'))
          end

          expect(responses.first['login']).to eq('mjacobus')
          expect(responses.last['login']).to eq('dhh')
        end
      end

      it 'queues requests with block' do
        VCR.use_cassette('koine_rest_client_client_async') do
          values = []
          requests = [
            GithubUserRequest.new('mjacobus'),
            GithubUserRequest.new('dhh'),
          ]
          responses = client.async do |async|
            async.perform_requests(requests) do |response|
              values << response['login']
            end
          end

          expect(responses.map { |r| r['login']}).to eq(['mjacobus', 'dhh'])
          expect(values).to eq(['mjacobus', 'dhh'])
        end
      end
    end
  end
end
