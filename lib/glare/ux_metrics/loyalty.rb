# frozen_string_literal: true

module Glare
  module UxMetrics
    module Loyalty
      class Parser
        def initialize(choices:)
          @choices = choices
        end

        attr_reader :choices

        def valid?
          return false unless choices.is_a?(Array) && choices.size == 11

          true
        end

        def parse
          validate!

          threshold = if nps_score >= 0.3
            "positive"
          elsif nps_score >= 0.0
            "neutral"
          else
            "negative"
          end

          label = if threshold == "positive"
                    "High"
                  elsif threshold == "neutral"
                    "Average"
                  else
                    "Low"
                  end

          Result.new(result: nps_score, threshold: threshold, label: label)
        end

        def breakdown
          {
            promoters: choices[0..1].sum,
            passives: choices[2..3].sum,
            detractors: choices[4..10].sum
          }
        end

        def nps_score
          @nps_score ||= choices[0..1].sum - choices[4..10].sum
        end

        class InvalidDataError < Error
          def initialize(data, msg = nil)
            @data = data
            super(msg || "#{data.to_json} is not valid. Correct data format is: \n\n#{correct_data}")
          end

          private

          attr_reader :data

          def correct_data
            [
              0.1, # highest
              0.2,
              0.1,
              0.05,
              0.09,
              0.05,
              0.1,
              0.01,
              0.02,
              0.01,
              0.02 # lowest
            ].to_json
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

