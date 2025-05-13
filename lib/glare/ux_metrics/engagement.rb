# frozen_string_literal: true

module Glare
  module UxMetrics

    module Engagement
      class Parser
        PRIMARY_WEIGHT = 1.0
        SECONDARY_WEIGHT = 1.0
        TERTIARY_WEIGHT = 1.0

        def initialize(primary_clicks_count:, secondary_clicks_count:, tertiary_clicks_count:, total_clicks_count:)
          @primary_clicks_count = primary_clicks_count
          @secondary_clicks_count = secondary_clicks_count
          @tertiary_clicks_count = tertiary_clicks_count
          @total_clicks_count = total_clicks_count
        end

        attr_reader :primary_clicks_count, :secondary_clicks_count, :tertiary_clicks_count, :total_clicks_count

        def valid?
          return false unless primary_clicks_count.is_a?(Integer) && secondary_clicks_count.is_a?(Integer) && tertiary_clicks_count.is_a?(Integer) && total_clicks_count.is_a?(Integer)

          true
        end

        def parse
          primary_score = (primary_clicks_count / total_clicks_count.to_f) * PRIMARY_WEIGHT
          secondary_score = (secondary_clicks_count / total_clicks_count.to_f) * SECONDARY_WEIGHT
          tertiary_score = (tertiary_clicks_count / total_clicks_count.to_f) * TERTIARY_WEIGHT

          result = primary_score + secondary_score + tertiary_score

          label = if result > 0.7
                    "High"
                  elsif result >= 0.5
                    "Avg"
                  else
                    "Low"
                  end

          threshold = if label == "High"
                        "positive"
                      elsif label == "Avg"
                        "neutral"
                      else
                        "negative"
                      end

          Result.new(result: result, threshold: threshold, label: label)
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

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
      end
    end
  end
end


