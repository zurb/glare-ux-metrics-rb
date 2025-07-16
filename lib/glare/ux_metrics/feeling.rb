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
          @result ||= positive_sentiment / total_sentiment.to_f
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
                       "Very High Sentiment"
                     elsif threshold == "positive"
                       "High Sentiment"
                     elsif threshold == "neutral"
                       "Avg Sentiment"
                     elsif threshold == "negative"
                       "Low Sentiment"
                     else
                       "Very Low Sentiment"
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

        def positive_sentiment
          @positive_sentiment ||= choices[:joy].to_f +
                                  choices[:trust].to_f
        end

        def negative_sentiment
          @negative_sentiment ||= choices[:anger].to_f +
                                  choices[:disgust].to_f +
                                  choices[:sadness].to_f +
                                  choices[:fear].to_f
        end

        def neutral_sentiment
          @neutral_sentiment ||= choices[:anticipation].to_f +
                                 choices[:surprise].to_f
        end

        def total_sentiment
          @total_sentiment ||= positive_sentiment.to_f +
                               negative_sentiment.to_f +
                               neutral_sentiment.to_f
        end
      end
    end
  end
end
