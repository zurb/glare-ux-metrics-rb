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
          validate!

          primary_score = (primary_clicks_count / total_clicks_count.to_f) * PRIMARY_WEIGHT
          secondary_score = (secondary_clicks_count / total_clicks_count.to_f) * SECONDARY_WEIGHT
          tertiary_score = (tertiary_clicks_count / total_clicks_count.to_f) * TERTIARY_WEIGHT

          result = primary_score + secondary_score + tertiary_score

          threshold = if result > 0.9
                        "very positive"
                      elsif result > 0.7
                        "positive"
                      elsif result > 0.5
                        "neutral"
                      elsif result > 0.3
                        "negative"
                      else
                        "very negative"
                      end

          label = if threshold == "very positive"
                    "Very High"
                  elsif threshold == "positive"
                    "High"
                  elsif threshold == "neutral"
                    "Avg"
                  elsif threshold == "negative"
                    "Fell Short"
                  elsif threshold == "very negative"
                    "Failed"
                  end

          Result.new(result: result, threshold: threshold, label: label)
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
              primary_clicks_count: "integer",
              secondary_clicks_count: "integer",
              tertiary_clicks_count: "integer",
              total_clicks_count: "integer",
            }.to_json
          end
        end

        private

        def data
          @data ||= {
            primary_clicks_count: primary_clicks_count,
            secondary_clicks_count: secondary_clicks_count,
            tertiary_clicks_count: tertiary_clicks_count,
            total_clicks_count: total_clicks_count
          }
        end

        def validate!
          raise InvalidDataError, data unless valid?
        end
      end
    end
  end
end


