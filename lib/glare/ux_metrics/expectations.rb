# frozen_string_literal: true

module Glare
  module UxMetrics
    module Expectations
      class Parser
        CHOICE_KEYS = %w[failed_expectations fell_short_of_expectations neutral met_expectations exceeded_expectations].freeze
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

          threshold = if result >= 0.9
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

          label = if threshold == "very positive"
                    "Very High"
                  elsif threshold == "positive"
                    "High"
                  elsif threshold == "neutral"
                    "Met"
                  elsif threshold == "negative"
                    "Fell Short"
                  elsif threshold == "very negative"
                    "Failed"
                  end

          Result.new(result: result, threshold: threshold, label: label)
        end

        def result
          @result ||= begin
            a = choices[:exceeded_expectations] * 5
            b = choices[:met_expectations] * 4
            c = choices[:neutral] * 3
            d = choices[:fell_short_of_expectations] * 2
            e = choices[:failed_expectations] * 1

            ((a + b + c + d + e) / 5).round(2)
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
                failed_expectations: "string|integer|float",
                fell_short_of_expectations: "string|integer|float",
                neutral: "string|integer|float",
                met_expectations: "string|integer|float",
                exceeded_expectations: "string|integer|float",
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
