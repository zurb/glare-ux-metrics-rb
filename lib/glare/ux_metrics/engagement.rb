# frozen_string_literal: true

module Glare
  module UxMetrics

    module Engagement
      class Parser
        def initialize(scores:, clicks:)
          @scores = scores
          @clicks = clicks
        end

        attr_reader :scores, :clicks

        def valid?
          return false unless scores.is_a?(Hash) && clicks.is_a?(Array) && scores.keys.size.positive? && clicks.size.positive?

          true
        end

        def parse
          hotspot_1_clicks = clicks.filter {|click| click.hotspot.zero? }
          hotspot_2_clicks = clicks.filter {|click| click.hotspot == 1 }
          hotspot_3_clicks = clicks.filter {|click| click.hotspot == 3 }

          primary_score = (hotspot_1_clicks.size / clicks.size.to_f) * 100
          secondary_score = (hotspot_2_clicks.size / clicks.size.to_f) * 100
          tertiary_score = (hotspot_3_clicks.size / clicks.size.to_f) * 100

          result = primary_score + secondary_score + tertiary_score

          label = if result > 0.3
                    "High"
                  elsif result >= 0.1
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


