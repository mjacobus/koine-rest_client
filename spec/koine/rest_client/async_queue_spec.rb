# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Koine::RestClient::AsyncQueue do
  subject(:queue) { described_class.new }

  let(:handler) { proc { |response| "the-#{response}" } }
  let(:request) { double(:request, name: 'one') }
  let(:second_request) { double(:request, name: 'two') }

  before do
    queue.push(request, &handler)
  end

  it 'adds requests' do
    queue.push(second_request, &handler)
    storage = []

    queue.each do |request, handler|
      storage.push(request)
      storage.push(handler.call(request.name))
    end

    expect(storage).to eq([request, 'the-one', second_request, 'the-two'])
  end

  it 'maps the request' do
    queue.push(second_request, &handler)
    storage = []

    queue.map do |request, handler|
      storage.push(request)
      storage.push(handler.call(request.name))
    end

    expect(storage).to eq([request, 'the-one', second_request, 'the-two'])
  end

  it 'clears the queue' do
    queue.clear

    expect(queue.to_a).to eq([])
  end
end
