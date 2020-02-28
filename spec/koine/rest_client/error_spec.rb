# frozen_string_literal: true

RSpec.describe Koine::RestClient::Error do
  subject(:error) { described_class.new(response) }

  let(:response) { instance_double(HTTParty::Response) }

  it { is_expected.to be_a(StandardError) }

  it 'includes the http response information' do
    expect(error.response).to be response
  end
end
