# frozen_string_literal: true

module Glare
  module UxMetrics
    module Sentiment
      # Run Glare::UxMetrics::Sentiment::Parser.new({...}) to create a parser
      class Parser
        CHOICE_KEYS = %w[helpful innovative simple joyful complicated confusing overwhelming annoying].freeze

        # @example Create a parser
        #   data = {
        #     helpful: 0.4,
        #     innovative: 0.2,
        #     joyful: 0.0,
        #     simple: 0.1,
        #     complicated: 0.05,
        #     confusing: 0.0,
        #     overwhelming: 0.0,
        #     annoying: 0.0
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

            true if v.is_a?(Float) || v.is_a?(Integer)
          end

          true
        end

        def parse
          validate!

          Result.new(result: result, threshold: threshold, label: threshold)
        end

        def result
          @result ||= choices[:helpful].to_f +
                      choices[:innovative].to_f +
                      choices[:simple].to_f +
                      choices[:joyful].to_f -
                      choices[:complicated].to_f -
                      choices[:confusing].to_f -
                      choices[:overwhelming].to_f -
                      choices[:annoying].to_f
        end

        def threshold
          @threshold ||= if result >= 1.5
                           "positive"
                         elsif result >= 1.0
                           "neutral"
                         else
                           "negative"
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
                helpful: "string|integer|float",
                innovative: "string|integer|float",
                simple: "string|integer|float",
                joyful: "string|integer|float",
                complicated: "string|integer|float",
                confusing: "string|integer|float",
                overwhelming: "string|integer|float",
                annoying: "string|integer|float",
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
