# frozen_string_literal: true

module Glare
  module UxMetrics
    module Intent
      class Parser
        CHOICE_KEYS = %w[primary secondary tertiary].freeze

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
          @result ||= begin
            primary = choices[:primary].to_f * 3
            secondary = choices[:secondary].to_f * 2
            tertiary = choices[:tertiary].to_f

            (primary + secondary + tertiary) / 3
          end
        end

        def threshold
          @threshold ||= if result > 0.6
                           "positive"
                         elsif result >= 0.4
                           "neutral"
                         else
                           "negative"
                         end
        end

        def label
          @label ||= if threshold == "positive"
                       "High Intent"
                     elsif threshold == "neutral"
                       "Avg Intent"
                     else
                       "Low Intent"
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
                primary: "string|integer|float",
                secondary: "string|integer|float",
                tertiary: "string|integer|float",
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

