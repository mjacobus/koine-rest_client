# frozen_string_literal: true

RSpec.describe Koine::RestClient::InternalServerError do
  subject(:error) { described_class.new(response) }

  let(:response) { instance_double(HTTParty::Response) }

  it { is_expected.to be_a(Koine::RestClient::Error) }
end
