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
          validate!

          Result.new(result: result, threshold: threshold, label: label)
        end

        def result
          @result ||= (((choices[:very_frequently].to_f * 5) +
                      (choices[:frequently].to_f * 4) +
                      (choices[:occasionally].to_f * 3) +
                      (choices[:rarely].to_f * 2) +
                      choices[:very_frequently].to_f) / 5).round(2)
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
                       "Avg"
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
                very_frequently: "string|integer|float",
                frequently: "string|integer|float",
                occasionally: "string|integer|float",
                rarely: "string|integer|float",
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

