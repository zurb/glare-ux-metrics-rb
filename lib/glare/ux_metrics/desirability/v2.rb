# frozen_string_literal: true

module Glare
  module UxMetrics
    module Desirability
      module V2
        class Parser
          SENTIMENT_CHOICE_KEYS = %w[helpful innovative simple joyful complicated confusing unnecessary uninteresting].freeze
          LIKERT_CHOICE_KEYS = %w[very_unlikely somewhat_unlikely neutral somewhat_likely very_likely].freeze

          def initialize(questions:)
            @questions = questions
          end

          attr_reader :questions

          def valid?
            return false unless questions.is_a?(Array) && questions.size == 2

            sentiment = questions.first
            likert = questions.last

            return false unless valid_sentiment_question?(sentiment)

            return false unless valid_likert_question?(likert)

            true
          end

          def no_promoters_for_question?(question)
            if question.is_a?(Array)
              (question[0] + question[1]).zero?
            elsif question.is_a?(Hash)
              (question[:very_interested].to_f + question[:moderately_interested].to_f).zero?
            end
          end

          def parse
            sentiment = questions.first
            likert = questions.last

            sentiment_score = calculate_sentiment_question(sentiment)
            likert_score = calculate_likert_question(likert)

            result = (sentiment_score + likert_score) / 2

            threshold = if result >= 0.8
                          "positive"
                        elsif result >= 0.6
                          "neutral"
                        else
                          "negative"
                        end

            label = if threshold == "positive"
                      "Good"
                    elsif threshold == "neutral"
                      "Neutral"
                    else
                      "Bad"
                    end

            Result.new(result: result, threshold: threshold, label: label)
          end

          def breakdown
            sentiment = questions.first
            likert = questions.last

            {
              sentiment_score: calculate_sentiment_question(sentiment),
              likert_score: calculate_likert_question(likert)
            }
          end

          def calculate_sentiment_question(question)
            positive_acc = question[:helpful].to_f + question[:innovative].to_f + question[:simple].to_f + question[:joyful].to_f
            negative_acc = question[:complicated].to_f + question[:confusing].to_f + question[:unnecessary].to_f + question[:uninteresting].to_f
            positive_acc / (positive_acc + negative_acc).to_f
          end

          def calculate_likert_question(question)
            acc = question[:very_unlikely].to_f +
              (question[:somewhat_unlikely].to_f * 2) +
              (question[:neutral].to_f * 3) +
              (question[:somewhat_likely].to_f * 4) +
              (question[:very_likely].to_f * 5)

            acc / 5.0
          end

          def valid_sentiment_question?(question)
            return false unless question.is_a?(Hash)
            missing_attributes = SENTIMENT_CHOICE_KEYS - question.keys.map(&:to_s)
            return false unless missing_attributes.empty?

            return false unless question.values.all? do |v|
              return Glare::Util.str_is_integer?(v) if v.is_a?(String)

              (v.is_a?(Integer) || v.is_a?(Float))
            end

            true
          end

          def valid_likert_question?(question)
            return false unless question.is_a?(Hash)

            missing_attributes = LIKERT_CHOICE_KEYS - question.keys.map(&:to_s)
            return false unless missing_attributes.empty?

            return false unless question.values.all? do |v|
              return Glare::Util.str_is_integer?(v) if v.is_a?(String)

              (v.is_a?(Integer) || v.is_a?(Float))
            end

            true
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
                  helpful: "string|integer|float",
                  innovative: "string|integer|float",
                  simple: "string|integer|float",
                  joyful: "string|integer|float",
                  complicated: "string|integer|float",
                  confusing: "string|integer|float",
                  unnecessary: "string|integer|float",
                  uninteresting: "string|integer|float"
                },
                likert: {
                  very_unlikely: "string|integer|float",
                  somewhat_unlikely: "string|integer|float",
                  neutral: "string|integer|float",
                  somewhat_likely: "string|integer|float",
                  very_likely: "string|integer|float"
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
