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
          Result.new(result: result, threshold: threshold, label: label)
        end

        def breakdown
          {
            promoters: choices[0..1].sum,
            passives: choices[2..3].sum,
            detractors: choices[4..10].sum
          }
        end

        def label
          @label ||= if threshold == "very positive"
                       "Very High"
                     elsif threshold == "positive"
                       "High"
                     elsif threshold == "neutral"
                       "Average"
                     elsif threshold == "negative"
                       "Low"
                     else
                       "Very Low"
                     end
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
          @result ||= (((nps_score * 100.0) + 100) / 200.0).round(2)
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
