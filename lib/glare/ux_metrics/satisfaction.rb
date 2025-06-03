# frozen_string_literal: true

module Glare
  module UxMetrics
    module Satisfaction
      # Run Glare::UxMetrics::Satisfaction::Parser.new({...}) to create a parser
      class Parser
        CHOICE_KEYS = %w[very_dissatisfied somewhat_dissatisfied neutral somewhat_satisfied very_satisfied].freeze
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

          threshold = if result > 0.8
                        "positive"
                      elsif result > 0.6
                        "neutral"
                      else
                        "negative"
                      end

          label = if threshold == "positive"
                    "High"
                  elsif threshold == "neutral"
                    "Avg"
                  else
                    "Low"
                  end

          Result.new(result: result, threshold: threshold, label: label)
        end

        def result
          @result ||= choices[:very_satisfied].to_f + choices[:somewhat_satisfied].to_f
        end

        class InvalidDataError < Error
          def initialize(msg = "#{data.to_json} is not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

          def correct_data
            {
              choices: {
                very_satisfied: "string|integer|float",
                somewhat_satisfied: "string|integer|float",
                neutral: "string|integer|float",
                somewhat_dissatisfied: "string|integer|float",
                very_dissatisfied: "string|integer|float",
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
