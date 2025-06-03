# frozen_string_literal: true

module Glare
  module UxMetrics
    module Desirability
      module V1
        class Parser
          CHOICE_KEYS = %w[very_interested moderately_interested slightly_interested not_interested].freeze

          def initialize(questions:)
            @questions = questions
          end

          attr_reader :questions

          def valid?
            return false unless questions.is_a?(Array) && questions.size

            return false unless questions.all? do |question|
              if question.is_a?(Hash)
                missing_attributes = CHOICE_KEYS - question.keys.map(&:to_s)
                return false unless missing_attributes.empty?

                question.values.all? do |v|
                  return Glare::Util.str_is_integer?(v) if v.is_a?(String)

                  (v.is_a?(Integer) || v.is_a?(Float))
                end

                true
              elsif question.is_a?(Array)
                return false unless question.size == 10

                return false unless question.all? do |v|
                  return Glare::Util.str_is_integer?(v) if v.is_a?(String)

                  (v.is_a?(Integer) || v.is_a?(Float))
                end

                true
              else
                false
              end
            end

            true
          end

          def no_promoters_for_question?(question)
            if question.is_a?(Array)
              (question[0] + question[1]).zero?
            elsif question.is_a?(Hash)
              (question[:very_interested].to_f + question[:moderately_interested].to_f).zero?
            end
          end

          def parse(question_index:)
            scored_questions = []
            questions.each_with_index do |question, index|
              scored_questions.push({
                                      score: calculate_question(question),
                                      no_promoters: no_promoters_for_question?(question),
                                      question: question,
                                      selected: index == question_index
                                    })
            end

            ordered_scored_questions = scored_questions.sort_by do |question|
              question[:score]
            end

            ordered_scored_questions.each_with_index do |question, index|
              # append :fraction property [whole number]/5
              next question[:fraction] = "5/5" if question[:score] >= 0.95

              prev_index = index - 1
              prev_question = ordered_scored_questions[prev_index]

              same_as_prev = if prev_question.nil?
                               false
                             else
                               prev_question[:score] == question[:score]
                             end

              if same_as_prev && !prev_question[:fraction].nil?
                question[:fraction] = prev_question[:fraction]
              else
                numerator = (((index + 1) / questions.length.to_f) * 5).round
                denominator = 5

                question[:fraction] = "#{numerator}/#{denominator}"
              end
            end

            selected_scored_question = ordered_scored_questions.find do |question|
              question[:selected]
            end

            result = selected_scored_question[:score]

            label = selected_scored_question[:fraction]

            threshold = if %w[5/5 4/5].include? label
                          "positive"
                        elsif label == "3/5"
                          "neutral"
                        else
                          "negative"
                        end

            Result.new(result: result, threshold: threshold, label: label)
          end

          def calculate_question(question)
            if question.is_a? Hash
              question[:very_interested].to_f + question[:moderately_interested].to_f - question[:slightly_interested].to_f - question[:not_interested].to_f
            else
              question[0].to_f + question[1].to_f - question[4].to_f - question[5].to_f - question[6].to_f - question[7].to_f - question[8].to_f - question[9].to_f
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
                sentiment: {
                  positive: "string|integer|float",
                  neutral: "string|integer|float",
                  negative: "string|integer|float",
                },
                choices: {
                  matched_very_well: "string|integer|float",
                  somewhat_matched: "string|integer|float",
                  neutral: "string|integer|float",
                  somewhat_didnt_match: "string|integer|float",
                  didnt_match_at_all: "string|integer|float",
                }
              }.to_json
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
        end
      end
    end
  end
end
