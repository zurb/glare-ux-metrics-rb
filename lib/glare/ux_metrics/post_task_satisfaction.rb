# frozen_string_literal: true

module Glare
  module UxMetrics
    module PostTaskSatisfaction
      class Parser
        CHOICE_KEYS = %w[very_satisfied somewhat_satisfied neutral somewhat_dissatisfied very_dissatisfied].freeze

        def initialize(choices:)
          @choices = choices
        end

        attr_reader :choices

        def valid?
          return false unless choices.is_a?(Hash) && choices.size

          missing_attributes = CHOICE_KEYS - choices.keys.map(&:to_s)
          return false unless missing_attributes.empty?

          return false unless choices.values.all? do |v|
            return Glare::Util.str_is_integer?(v) if v.is_a?(String)

            true if v.is_a?(Float) || v.is_a?(Integer)
          end

          true
        end

        def parse
          result = choices[:very_satisfied].to_f +
                   choices[:somewhat_satisfied].to_f -
                   choices[:neutral].to_f -
                   choices[:somewhat_dissatisfied].to_f -
                   choices[:very_dissatisfied].to_f

         threshold = if result >= 0.7
                       "positive"
                     elsif result > 0.5
                       "neutral"
                     else
                       "negative"
                     end

          label = if threshold == "positive"
                    "High Satisfaction"
                  elsif threshold == "neutral"
                    "Average Satisfaction"
                  else
                    "Low Satisfaction"
                  end

          Result.new(result: result, threshold: threshold, label: label)
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

          def correct_data
            {
              very_satisfied: "string|integer|float",
              somewhat_satisfied: "string|integer|float",
              neutral: "string|integer|float",
              somewhat_dissatisfied: "string|integer|float",
              very_dissatisfied: "string|integer|float",
            }.to_json
          end
        end
      end
    end
  end
end
