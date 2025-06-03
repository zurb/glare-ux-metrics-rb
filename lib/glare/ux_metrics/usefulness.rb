# frozen_string_literal: true

module Glare
  module UxMetrics
    module Usefulness
      # Run Glare::UxMetrics::Usefulness::Parser.new({...}) to create a parser
      class Parser
        CHOICE_KEYS = %w[strongly_disagree disagree neutral agree strongly_agree].freeze

        # @example Create a parser
        #   questions = [{
        #     strongly_disagree: 0.1,
        #     disagree: 0.1,
        #     neutral: 0.1,
        #     agree: 0.1,
        #     strongly_agree: 0.1,
        #   }]
        #   Glare::UxMetrics::Usefulness::Parser.new(questions: questions)
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
          def initialize(msg = "#{data.to_json} is not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

          def correct_data
            example = {}
            CHOICE_KEYS.each { |k| example[k] = "string|integer|float" }
            [example].to_json
          end
        end

        private

        def data
          @data ||= {
            questions: questions
          }
        end

        def validate!
          raise InvalidDataError unless valid?
        end

        def valid_question?(question)
          return false unless question.is_a?(Hash)

          return false unless (question.keys.map(&:to_s) - CHOICE_KEYS).size.zero?

          true
        end

        def score
          @score ||= questions.map { |question| question_score(question) }.sum / questions.size
        end

        def question_score(question)
          convert_to_hundred_point_scale(
            question_weighted_score(question) / question_unweighted_score(question),
            max: question.keys.size
          )
        end

        def question_weighted_score(question)
          question[:strongly_disagree] +
            (question[:disagree] * 2) +
            (question[:neutral] * 3) +
            (question[:agree] * 4) +
            (question[:strongly_agree] * 5)
        end

        def question_unweighted_score(question)
          question[:strongly_disagree] +
            question[:disagree] +
            question[:neutral] +
            question[:agree] +
            question[:strongly_agree]
        end

        # Converts a number from one scale to a 0-100 scale
        # @param [Float] num the number to convert
        # @param [Float] min the minimum value of the original scale
        # @param [Float] max the maximum value of the original scale
        # @return [Float] the converted value on a 0-100 scale
        def convert_to_hundred_point_scale(num, max:, min: 1)
          ((num - min) / (max - min).to_f) * 100
        end

        def label
          @label ||= if score >= 0.8
                       "High"
                     elsif score >= 0.6
                       "Average"
                     else
                       "Low"
                     end
        end

        def threshold
          @threshold ||= if label == "High"
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
