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
            [{
              average_primary_percentage: "string|integer|float",
              average_secondary_percentage: "string|integer|float",
              average_tertiary_percentage: "string|integer|float"
            }].to_json
          end
        end

        private

        def data
          @data ||= {
            questions: questions
          }
        end

        def validate!
          raise InvalidDataError, data unless valid?
        end

        def valid_question?(question)
          return false unless question.is_a?(Hash)

          return false unless question.key?(:average_primary_percentage)
          return false unless question.key?(:average_secondary_percentage)
          return false unless question.key?(:average_tertiary_percentage)

          true
        end

        def score
          @score ||= begin
            primary_percentages = questions.reject { |question| question[:average_primary_percentage].nil? }.map { |question| question[:average_primary_percentage] }
            secondary_percentages = questions.reject { |question| question[:average_secondary_percentage].nil? }.map { |question| question[:average_secondary_percentage] }
            tertiary_percentages = questions.reject { |question| question[:average_tertiary_percentage].nil? }.map { |question| question[:average_tertiary_percentage] }


            non_nil_percentages = primary_percentages + secondary_percentages + tertiary_percentages

            return 0 if non_nil_percentages.empty?

            non_nil_percentages.sum / non_nil_percentages.size
          end
        end

        def label
          @label ||= if threshold == "very positive"
                       "Very Good"
                     elsif threshold == "positive"
                       "Good"
                     elsif threshold == "neutral"
                       "Avg"
                     elsif threshold == "negative"
                       "Low"
                     else
                       "Very Low"
                     end
        end

        def threshold
          @threshold ||= if score >= 0.9
                           "very positive"
                         elsif score >= 0.7
                           "positive"
                         elsif score >= 0.5
                           "neutral"
                         elsif score >= 0.3
                           "negative"
                         else
                           "very negative"
                         end
        end
      end
    end
  end
end


