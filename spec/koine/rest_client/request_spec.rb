# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Koine::RestClient::Request do
  subject(:request) { described_class.new(**arguments) }

  let(:arguments) do
    {
      method: 'put',
      path: '/foo',
      base_url: 'http://base_url',
      headers: { h1: :v1 },
      query_params: { q1: :v1 }
    }
  end

  it 'properly sets arguments given in the constructor' do
    expect(request).to be_equal_to(request.with_added_options(arguments))
  end

  it 'mutates method' do
    new_request = request.with_method('post')

    assert_attribute(new_request, :method, 'post')
  end

  it 'mutates #base_url' do
    new_request = request.with_base_url('foo')

    assert_attribute(new_request, :base_url, 'foo')
  end

  it 'mutates body' do
    new_request = request.with_body('the-body')

    assert_attribute(new_request, :body, 'the-body')
  end

  it 'does not convert to json when content type is not json' do
    new_request = request.with_body(foo: :bar)

    assert_attribute(new_request, :body, { foo: :bar })
  end

  it 'body gets converted to json when content type is json' do
    new_request = request
      .with_added_headers('Content-Type' => 'application/json; charset=UTF-8')
      .with_body(foo: :bar)

    assert_attribute(new_request, :body, '{"foo":"bar"}')
  end

  it 'mutates path' do
    new_request = request.with_path('the-path')

    assert_attribute(new_request, :path, 'the-path')
  end

  it 'mutates headers with #with_added_headers' do
    new_request = request.with_added_headers(h2: :v2)

    expected = { h1: :v1, h2: :v2 }

    assert_attribute(new_request, :headers, expected)
  end

  it 'removes headers with nil values' do
    new_request = request.with_added_headers(h1: nil, h2: :v2)

    expected = { h2: :v2 }

    assert_attribute(new_request, :headers, expected)
  end

  it 'mutates query_params with #with_added_query_params' do
    new_request = request.with_added_query_params(q2: :v2)

    expected = { q1: :v1, q2: :v2 }

    assert_attribute(new_request, :query_params, expected)
  end

  it 'removes query_params witq nil values' do
    new_request = request.with_added_query_params(q1: nil, q2: :v2)

    expected = { q2: :v2 }

    assert_attribute(new_request, :query_params, expected)
  end

  describe '#url' do
    it 'assembles the url correctly' do
      expect(request.with_base_url('https://url/').with_path('/bar').url).to eq('https://url/bar?q1=v1')
      expect(request.with_base_url('https://url').with_path('bar').url).to eq('https://url/bar?q1=v1')
    end
  end

  describe '#options' do
    it 'does not include method' do
      expect(request.options.key?(:method)).to be false
    end

    it 'does not include path' do
      expect(request.options.key?(:path)).to be false
    end

    it 'does not include base url' do
      expect(request.options.key?(:base_url)).to be false
    end

    it 'ommits body when it is empty' do
      expect(request.options.key?(:body)).to be false
    end

    it 'includes body when it is given' do
      new_request = request.with_body('the-body')
      expect(new_request.options[:body]).to eq 'the-body'
    end

    it 'includes headers' do
      expect(request.options[:headers]).to eq(h1: :v1)
    end

    it 'ommit headers when empty' do
      request = described_class.new

      expect(request.options.key?(:headers)).to be false
    end
  end

  describe '#with_added_options' do
    it 'adds all options' do
      new_request = request.with_added_options(
        method: 'post',
        base_url: 'new-base-url',
        path: '/the/path',
        headers: { h2: :v2 },
        query_params: { q2: :v2 },
        body: 'the-new-body'
      )

      assert_attribute(new_request, :method, 'post')
      assert_attribute(new_request, :base_url, 'new-base-url')
      assert_attribute(new_request, :path, '/the/path')
      assert_attribute(new_request, :headers, h1: :v1, h2: :v2)
      assert_attribute(new_request, :query_params, q1: :v1, q2: :v2)
      assert_attribute(new_request, :body, 'the-new-body')
    end
  end

  def assert_attribute(object, attribute, value)
    expect(object.send(attribute)).to eq value
    expect(object).not_to be(request)
    expect(object).to be_frozen
    expect(request.send(attribute)).not_to eq value
  end
end
