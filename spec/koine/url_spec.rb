# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Koine::Url do
  subject(:url) { klass.new('https://google.com') }

  let(:klass) { described_class }

  it 'can be converted to string' do
    url = klass.new(klass.new('https://google.com'))

    expect(url.to_s).to eq('https://google.com')
  end

  describe 'initialize' do
    it 'raises ArgumentError when schema is missing' do
      expect { klass.new('example.com') }.to raise_error(
        klass::ArgumentError, "Invalid url 'example.com'"
      )
    end

    it 'raises ArgumentError it is only relative' do
      expect { klass.new('foo/bar') }.to raise_error(
        klass::ArgumentError, "Invalid url 'foo/bar'"
      )
    end
  end

  describe '#with_query_params' do
    it 'appends query params to the url' do
      new = with_immutable(url) do |url|
        url.with_query_params(foo: :bar, bar: :baz)
      end

      expect(new.to_s).to eq('https://google.com?bar=baz&foo=bar')
    end

    it 'replaces the existing query params' do
      new = with_immutable(url) do |url|
        url.with_query_params(foo: :bar, bar: :baz)
          .with_query_params(a: :b)
      end

      expect(new.to_s).to eq('https://google.com?a=b')
    end

    it 'removes query params when params are empty' do
      new = with_immutable(url) do |url|
        url.with_query_params(foo: :bar, bar: :baz).with_query_params({})
      end

      expect(new).to eq(url)
    end
  end

  describe '#with_query_param' do
    it 'appends single params to the url' do
      new = with_immutable(url) do |url|
        url.with_query_param(:foo, :biz)
          .with_query_param(:foo, :bar)
          .with_query_param(:a, :b)
      end

      expect(new.to_s).to eq('https://google.com?a=b&foo=bar')
    end
  end

  describe '#to_s' do
    it 'does not encode commas' do
      new = with_immutable(url) do |url|
        url.with_query_param('a', 'b,c,d')
      end

      expected = 'https://google.com?a=b,c,d'

      expect(new.to_s(unescape: ',')).to eq(expected)
    end
  end

  describe '#query_params' do
    it 'returns the query params' do
      expected = { 'foo' => 'bar', 'bar' => 'baz' }

      params = url.with_query_params(expected).query_params

      expect(params).to eq(expected)
    end

    it 'returns empty hash when no query param exists' do
      params = url.query_params

      expect(params).to eq({})
    end
  end

  describe '#uri' do
    it 'returns the uri of the url' do
      url = klass.new('https://google.com/foo/bar?baz=1')

      expect(url.uri).to eq('/foo/bar?baz=1')
    end
  end
end
