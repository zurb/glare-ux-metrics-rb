# frozen_string_literal: true

module Glare
  module UxMetrics

    module Engagement
      class Parser
        def initialize(hotspot_clicks_count:, total_clicks_count:)
          @hotspot_clicks_count = hotspot_clicks_count
          @total_clicks_count = total_clicks_count
        end

        attr_reader :hotspot_clicks_count, :total_clicks_count

        def valid?
          return false unless hotspot_clicks_count.is_a?(Integer) && total_clicks_count.is_a?(Integer)

          true
        end

        def parse
          validate!

          result = hotspot_clicks_count / total_clicks_count.to_f

          threshold = if result >= 0.9
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
              hotspot_clicks_count: "integer",
              total_clicks_count: "integer",
            }.to_json
          end
        end

        private

        def data
          @data ||= {
            hotspot_clicks_count: hotspot_clicks_count,
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


