# frozen_string_literal: true

module Glare
  module UxMetrics
    class Error < StandardError; end

    class Result
      def initialize(result:, threshold:, label:)
        @result = result
        @threshold = threshold
        @label = label
      end

      def self.default
        Result.new(result: 0.0, threshold: "", label: "")
      end

      attr_reader :result, :threshold, :label
    end

    class ClickData
      def initialize(x_pos:, y_pos:, hotspot:)
        @x_pos = x_pos
        @y_pos = y_pos
        @hotspot = hotspot
      end

      attr_reader :x_pos, :y_pos, :hotspot

      def in_hotspot?
        hotspot > -1
      end
    end

  end
end
