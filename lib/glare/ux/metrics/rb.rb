# frozen_string_literal: true

require_relative "rb/version"

module Glare
  module UxMetrics
    class Error < StandardError; end
    def get_sentiment_score(data)
      raise Error.new("data needs to be in this format: { choices: [{ "" }] }") unless data.is_a? Hash

      raise Error.new("") unless data[:choices].is_a? Array

      result = 0
      section.variations.first.choices.each_with_index do |choice, i|
        multiplier = i > 3 ? -1 : 1
        result += choice.selected_percentage * multiplier
      end

      result
    end

    module Sentiment
      def parse_data(data)
        validate_data!(data)
      end

      def validate_data!(data)
        if data.is_a?(Hash) && data[:choices].is_a?(Hash) && data[:choices].size
          if data[:choices].keys.all? { |key| [:helpful, :innovative, :simple, :complicated, :confusing, :overwhelming, :annoying].include?(key) }
            return true
          end
        end

        raise InvalidDataError
      end

      class InvalidDataError < StandardError
        def initialize(msg="Data not valid. Correct data format is: \n\n#{correct_data.to_json}")
          super(msg)
        end

        def correct_data
          {
            choices: {
              helpful: "string",
              innovative: "string",
              simple: "string",
              joyful: "string",
              complicated: "string",
              confusing: "string",
              overwhelming: "string",
              annoying: "string",
            }
          }
        end
      end
    end
  end
end
