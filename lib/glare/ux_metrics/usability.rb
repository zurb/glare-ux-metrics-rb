# frozen_string_literal: true

module Glare
  module UxMetrics
    module Usability
      # Run Glare::UxMetrics::Usability::Parser.new({...}) to create a parser
      class Parser
        # @example Create a parser
        #   questions = [{
        #     average_primary_percentage: 0.4,
        #     average_secondary_percentage: 0.2,
        #     average_tertiary_percentage: 0.0,
        #   }]
        #   Glare::UxMetrics::Usability::Parser.new(questions: questions)
        def initialize(questions:)
          @questions = questions
        end

        attr_reader :questions

        def valid?
          return false unless questions.is_a?(Array) && questions.size.positive?

          return false unless questions.all? { |question| valid_question?(question) }

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
            [{
              average_primary_percentage: "string|integer|float",
              average_secondary_percentage: "string|integer|float",
              average_tertiary_percentage: "string|integer|float"
            }].to_json
          end
        end

        private

        def valid_question?(question)
          return false unless question.is_a?(Hash)

          return false unless question.key?(:average_primary_percentage)
          return false unless question.key?(:average_secondary_percentage)
          return false unless question.key?(:average_tertiary_percentage)

          true
        end

        def score
          @score ||= begin
            avg_primary_score = questions.map { |question| question[:average_primary_percentage] }.sum / questions.size
            avg_secondary_score = questions.map { |question| question[:average_secondary_percentage] }.sum / questions.size
            avg_tertiary_score = questions.map { |question| question[:average_tertiary_percentage] }.sum / questions.size

            (avg_primary_score + avg_secondary_score + avg_tertiary_score) / 3
          end
        end

        def label
          @label ||= if score >= 0.8
            "Good"
          elsif score >= 0.6
            "Avg"
          else
            "Low"
          end
        end

        def threshold
          @threshold ||= if label == "Good"
            "positive"
          elsif label == "Avg"
            "neutral"
          else
            "negative"
          end
        end
      end
    end
  end
end


