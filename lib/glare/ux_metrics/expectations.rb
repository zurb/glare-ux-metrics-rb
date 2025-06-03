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

          threshold = if result > 0.3
                        "positive"
                      elsif result > 0.1
                        "neutral"
                      else
                        "negative"
                      end

          label = if threshold == "positive"
                    "High"
                  elsif threshold == "neutral"
                    "Met"
                  else
                    "Failed"
                  end

          Result.new(result: result, threshold: threshold, label: label)
        end

        def result
          @result ||= begin
            positive_impressions = choices[:exceeded_expectations].to_f +
                                    choices[:met_expectations].to_f
            neutral_impressions = choices[:neutral].to_f
            negative_impressions = choices[:failed_expectations].to_f +
                                    choices[:fell_short_of_expectations].to_f

            positive_impressions - (neutral_impressions + negative_impressions)
          end
        end

        class InvalidDataError < Error
          def initialize(msg = "#{data.to_json} is not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

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
          raise InvalidDataError unless valid?
        end
      end
    end
  end
end
