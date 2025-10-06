# frozen_string_literal: true

module Glare
  module UxMetrics
    module Effort
      # Run Glare::UxMetrics::Effort::Parser.new({...}) to create a parser
      class Parser
        # @example Create a parser
        #   nps_question = {
        #     choices: [5, 5, 5, 4, 3, 4, 2, 1], # what each respondent chose
        #   }
        #   Glare::UxMetrics::Effort::Parser.new(questions: questions)
        def initialize(nps_question:)
          @nps_question = nps_question
        end

        attr_reader :nps_question

        def valid?
          return false unless nps_question.is_a?(Hash)

          return false unless nps_question.key?(:choices)

          return false unless nps_question[:choices].is_a?(Array)

          true
        end

        def parse
          validate!

          Result.new(result: score, threshold: threshold, label: label)
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
              nps_question: {
                choices: "Array<string|integer|float>"
              }
            }.to_json
          end
        end

        private

        def data
          @data ||= {
            nps_question: nps_question
          }
        end

        def validate!
          raise InvalidDataError, data unless valid?
        end

        def score
          @score = nps_question[:choices].sum / nps_question[:choices].count.to_f / 7
        end
      
        def label
          @label ||= if score >= 0.9
                       "Very Excellent"
                     elsif score >= 0.7
                       "Excellent"
                     elsif score >= 0.5
                       "Average"
                     elsif score >= 0.3
                       "Fell Short"
                     else
                       "Failed"
                     end
        end

        def threshold
          @threshold ||= if label == "Very Excellent"
                           "very positive"
                         elsif label == "Excellent"
                           "positive"
                         elsif label == "Average"
                           "neutral"
                         elsif label == "Fell Short"
                           "negative"
                         else
                           "very negative"
                         end
        end
      end
    end
  end
end
