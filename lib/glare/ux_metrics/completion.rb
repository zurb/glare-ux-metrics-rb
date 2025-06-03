# frozen_string_literal: true

module Glare
  module UxMetrics
    module Completion
      class Parser
        def initialize(direct_success:, indirect_success:)
          @direct_success = direct_success
          @indirect_success = indirect_success
        end

        attr_reader :direct_success, :indirect_success

        def valid?
          return false unless direct_success.is_a?(Float) && indirect_success.is_a?(Float)

          true
        end

        def parse
          validate!

          result = direct_success + indirect_success

          label = if result > 0.9
                    "Successful"
                  elsif result >= 0.75
                    "Avg"
                  else
                    "Failed"
                  end

          threshold = if label == "Successful"
                        "positive"
                      elsif label == "Avg"
                        "neutral"
                      else
                        "negative"
                      end

          Result.new(result: result, threshold: threshold, label: label)
        end

        class InvalidDataError < Error
          def initialize(msg = "#{data.to_json} is not valid. Correct data format is: \n\n#{correct_data}")
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

        private

          def data
            @data ||= {
              direct_success: direct_success,
              indirect_success: indirect_success
            }
          end

          def validate!
            raise InvalidDataError unless valid?
          end
      end
    end
  end
end
