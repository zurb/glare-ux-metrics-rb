# frozen_string_literal: true

module Glare
  module UxMetrics
    module Appeal
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
          validate!
          Result.new(result: result, threshold: threshold, label: threshold)
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


        def result
          @result ||= begin
            (choices[:very_satisfied].to_f * 5 +
            choices[:somewhat_satisfied].to_f * 4 +
            choices[:neutral].to_f * 3 +
            choices[:somewhat_dissatisfied].to_f * 2 +
            choices[:very_dissatisfied].to_f) / 5
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
              very_satisfied: "string|integer|float",
              somewhat_satisfied: "string|integer|float",
              neutral: "string|integer|float",
              somewhat_dissatisfied: "string|integer|float",
              very_dissatisfied: "string|integer|float",
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
