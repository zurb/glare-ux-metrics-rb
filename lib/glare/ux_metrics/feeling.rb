# frozen_string_literal: true

module Glare
  module UxMetrics
    module Feeling
      # Run Glare::UxMetrics::Feeling::Parser.new({...}) to create a parser
      class Parser
        CHOICE_KEYS = %w[anticipation surprise joy trust anger disgust sadness fear].freeze

        # @example Create a parser
        #   data = {
        #     anticipation: 0.4,
        #     surprise: 0.2,
        #     joy: 0.1,
        #     trust: 0.05,
        #     anger: 0.02,
        #     disgust: 0.0,
        #     sadness: 0.0,
        #     fear: 0.0
        #   }
        #   Glare::UxMetrics::Feeling::Parser.new(data)
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

            true
          end

          true
        end

        def parse
          validate!

          Result.new(result: result, threshold: threshold, label: label)
        end

        def result
          @result ||= choices[:joy].to_f +
                      choices[:trust].to_f -
                      choices[:anger].to_f -
                      choices[:disgust].to_f -
                      choices[:sadness].to_f -
                      choices[:fear].to_f
        end

        def threshold
          @threshold ||= if result > 0.3
                           "positive"
                         elsif result > 0.1
                           "neutral"
                         else
                           "negative"
                         end
        end

        def label
          @label ||= if threshold == "positive"
                       "High Sentiment"
                     elsif threshold == "neutral"
                       "Avg Sentiment"
                     else
                       "Low Sentiment"
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
                anticipation: "string|integer|float",
                surprise: "string|integer|float",
                joy: "string|integer|float",
                trust: "string|integer|float",
                anger: "string|integer|float",
                disgust: "string|integer|float",
                sadness: "string|integer|float",
                fear: "string|integer|float"
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
