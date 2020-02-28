# frozen_string_literal: true

module Koine
  module RestClient
    # queue for async requests
    class AsyncQueue
      def initialize
        @items = []
      end

      def push(item, &block)
        @items.push([item, block])
      end

      def each
        @items.each do |item|
          yield(item[0], item[1])
        end
      end

      def map
        @items.map do |item|
          yield(item[0], item[1])
        end
      end

      def clear
        @items.clear
      end

      def to_a
        @items.to_a
      end
    end
  end
end
