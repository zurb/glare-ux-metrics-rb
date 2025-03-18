# frozen_string_literal: true

module Glare
  module UxMetrics
    module Frequency
      class Parser
        CHOICE_KEYS = %w[very_frequently frequently occasionally rarely].freeze

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

            return true if v.is_a?(Float) || v.is_a?(Integer)

            false
          end

          true
        end

        def parse
          Result.new(result: result, threshold: threshold, label: label)
        end

        def result
          @result ||= choices[:very_frequently].to_f +
                      choices[:frequently].to_f -
                      choices[:occasionally].to_f -
                      choices[:rarely].to_f
        end

        def threshold
          @threshold ||= if result > 0.3
                           "positive"
                         elsif result >= 0.1
                           "neutral"
                         else
                           "negative"
                         end
        end

        def label
          @label ||= if threshold == "positive"
                       "High"
                     elsif threshold == "neutral"
                       "Avg"
                     else
                       "Low"
                     end
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

          def correct_data
            {
              choices: {
                very_frequently: "string|integer|float",
                frequently: "string|integer|float",
                occasionally: "string|integer|float",
                rarely: "string|integer|float",
              }
            }.to_json
          end
        end
      end
    end
  end
end

