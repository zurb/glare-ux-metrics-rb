# frozen_string_literal: true

module Glare
  module UxMetrics
    module Comprehension
      class Parser

        CHOICE_KEYS = %w[did_not_understand understood_a_little understood_most_of_it understood_very_well].freeze
        def initialize(choices:)
          @choices = choices
        end

        attr_reader :choices

        def valid?
          if choices.is_a?(Hash) && choices.size
            missing_attributes = CHOICE_KEYS - choices.keys.map(&:to_s)
            return false unless missing_attributes.empty?
          end

          true
        end

        def parse
          validate!
          Result.new(result: result, threshold: threshold, label: label)
        end

        def result
          @result ||= ((choices[:understood_very_well].to_f * 4) +
                        (choices[:understood_most_of_it].to_f * 3) +
                        (choices[:understood_a_little].to_f * 2) +
                        (choices[:did_not_understand].to_f * 1)) / 4
        end

        def threshold
          @threshold ||= if result >= 0.9
                           "very positive"
                         elsif result >= 0.7
                           "positive"
                          elsif result >= 0.5
                           "neutral"
                         elsif result >= 0.3
                           "negative"
                         else
                           "very negative"
                         end
        end

        def label
          @label ||= if threshold == "very positive"
                       "Very High"
                     elsif threshold == "positive"
                       "High"
                     elsif threshold == "neutral"
                       "Average"
                     elsif threshold == "negative"
                       "Low"
                     else
                       "Very Low"
                     end
        end

        class InvalidDataError < Error
          def initialize(data, msg = nil)
            @data = data
            super(msg || "#{data.to_json} is not valid. Correct data format is: \n\n#{correct_data}")
          end

          private

          attr_reader :data

          def correct_data
            {
              choices: {
                did_not_understand: "string|integer|float",
                understood_a_little: "string|integer|float",
                understood_most_of_it: "string|integer|float",
                understood_very_well: "string|integer|float",
              }
            }.to_json
          end
        end

        private

        def data
          @data ||= {
            choices: choices
          }
        end

        def validate!
          raise InvalidDataError, data unless valid?
        end
      end
    end
  end
end
