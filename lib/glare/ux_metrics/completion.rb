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

          Result.new(result: result, threshold: threshold, label: label)
        end
         
        def result
          @result ||= direct_success + indirect_success
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

        def label
          @label ||= if threshold == "very positive"
                       "Very Successful"
                     elsif threshold == "positive"
                       "Successful"
                     elsif threshold == "neutral"
                       "Avg"
                     elsif threshold == "negative"
                       "Somewhat Failed"
                     else
                       "Failed"
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
              direct_success: "float",
              indirect_success: "float"
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
            raise InvalidDataError, data unless valid?
          end
      end
    end
  end
end
