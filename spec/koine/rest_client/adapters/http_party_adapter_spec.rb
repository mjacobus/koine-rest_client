# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Koine::RestClient::Adapters::HttpPartyAdapter do
  subject(:adapter) { described_class.new(client) }

  let(:client) { class_double(HTTParty) }
  let(:request) do
    instance_double(
      Koine::RestClient::Request,
      url: 'the-url',
      method: request_method,
      headers: 'the-headers',
      body: 'the-body',
    )
  end

  %i[get post put patch delete].each do |method|
    context "when method is #{method}" do
      let(:request_method) { method }

      before do
        allow(client).to receive(method)
      end

      it 'handles request' do
        adapter.send_request(request)

        expect(client).to have_received(method).with('the-url', {body: 'the-body', headers: 'the-headers'})
      end
    end
  end
end
