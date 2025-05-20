
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
          Result.new(result: score, threshold: threshold, label: label)
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

          def correct_data
            {
              nps_question: {
                choices: "Array<string|integer|float>"
              }
            }.to_json
          end
        end

        private

        def score
          @score = nps_question[:choices].sum / nps_question[:choices].count.to_f / 5
        end
      
        def label
          @label ||= if score >= 0.8571
            "Excellent"
          elsif score >= 0.5714
            "Average"
          else
            "Low"
          end
        end

        def threshold
          @threshold ||= if label == "Excellent"
            "positive"
          elsif label == "Average"
            "neutral"
          else
            "negative"
          end
        end
      end
    end
  end
end
