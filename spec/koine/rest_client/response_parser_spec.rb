# frozen_string_literal: true

RSpec.describe Koine::RestClient::ResponseParser do
  subject(:parser) { described_class.new }

  let(:parsed) { parser.parse(response) }
  let(:response) do
    instance_double(
      HTTParty::Response,
      code: code,
      parsed_response: 'parsed-response'
    )
  end
  let(:code) { 200 }

  [
    200,
    201,
    202,
    203,
    204,
    205,
    206,
    207,
    208,
    226
  ].each do |response_code|
    let(:code) { response_code }

    it "returns parsed response when response_code is #{response_code}" do
      expect(parsed).to eq('parsed-response')
    end
  end

  it 'yields block' do
    storage = []

    parser.parse(response) do |r|
      storage << r
    end

    expect(storage).to eq([response])
  end

  context 'when response is 400' do
    let(:code) { 400 }

    it 'raises a bad request error' do
      expect { parsed }.to raise_error(Koine::RestClient::BadRequestError)
    end
  end

  context 'when response is 404' do
    let(:code) { 404 }

    it 'raises a bad request error' do
      expect { parsed }.to raise_error(Koine::RestClient::NotFoundError)
    end
  end

  context 'when response is 500' do
    let(:code) { 500 }

    it 'raises a bad request error' do
      expect { parsed }.to raise_error(Koine::RestClient::InternalServerError)
    end
  end

  context 'when response code is not expeced' do
    let(:code) { 27 }

    it 'raises a bad request error' do
      expect { parsed }.to raise_error(Koine::RestClient::Error)
    end
  end
end
