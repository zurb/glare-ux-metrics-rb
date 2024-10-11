# frozen_string_literal: true

module Glare
  module UxMetrics
    class Error < StandardError; end

    module Sentiment
      class Data
        CHOICE_KEYS = %w[helpful innovative simple complicated confusing overwhelming annoying].freeze

        def initialize(choices:)
          @choices = choices
        end

        attr_reader :choices

        def valid?
          if choices.is_a?(Hash) && choices.size
            missing_attributes = CHOICE_KEYS - choices.keys.map(&:to_s)
            return true if missing_attributes.empty?
          end

          false
        end

        def parse
          result = choices[:helpful].to_f +
            choices[:innovative].to_f +
            choices[:simple].to_f +
            choices[:joyful].to_f -
            choices[:complicated].to_f -
            choices[:confusing].to_f -
            choices[:overwhelming].to_f -
            choices[:annoying].to_f

          threshold = if result > 1.5
                        'positive'
                      elsif result > 1.0
                        'neutral'
                      else
                        'negative'
                      end

          Result.new(result: result, threshold: threshold, label: threshold)
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

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
      end
    end

    module Feeling
      class Data
        CHOICE_KEYS = %w[very_easy somewhat_easy neutral somewhat_difficult very_difficult].freeze

        def initialize(choices:)
          @choices = choices
        end

        attr_reader :choices

        def valid?
          if choices.is_a?(Hash) && choices.size
            missing_attributes = CHOICE_KEYS - choices.keys.map(&:to_s)
            return true if missing_attributes.empty?
          end

          false
        end

        def parse
          result = choices[:very_easy].to_f +
            choices[:somewhat_easy].to_f -
            choices[:neutral].to_f -
            choices[:somewhat_difficult].to_f -
            choices[:very_difficult].to_f

          threshold = if result > 1.5
                        'positive'
                      elsif result > 1.0
                        'neutral'
                      else
                        'negative'
                      end

          Result.new(result: result, threshold: threshold, label: threshold)
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

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
      end
    end

    class Result
      def initialize(result:, threshold:, label:)
        @result = result
        @threshold = threshold
        @label = label
      end

      attr_reader :result, :threshold, :label

    end
  end
end
