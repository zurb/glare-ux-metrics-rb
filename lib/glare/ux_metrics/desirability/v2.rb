# frozen_string_literal: true

module Glare
  module UxMetrics
    module Desirability
      module V2
        class Parser

      # def self.result(sections, filters: {}, memoized: true)
      #   sentiment_section = sections.first
      #   likert_section = sections.last
      #
      #   raise "no sentiment section for desirability V2" unless sentiment_section.present?
      #   raise "no likert section for desirability V2" unless likert_section.present?
      #
      #   sentiment_choices = sentiment_section.variations.first.choices
      #
      #   sentiment_score = 0
      #   total_impressions = 0
      #   sentiment_choices.each_with_index do |choice, index|
      #     case index
      #     when 0..3
      #       sentiment_score += choice.selected_percentage(filters, memoized: memoized).round
      #     end
      #
      #     total_impressions += choice.selected_percentage(filters, memoized: memoized).round
      #   end
      #
      #   sentiment_score = UxMetric.safe_divide(sentiment_score, total_impressions.to_f) * 100
      #
      #   likert_variation = likert_section.variations.first
      #   likert_score = if likert_variation.present?
      #     res = 0
      #
      #     likert_variation.choices.each_with_index do |choice, index|
      #       case index
      #       when 0 # Very Unlikely
      #         res += choice.selected_percentage(filters, memoized: memoized).round
      #       when 1 # Somewhat Unlikely
      #         res += choice.selected_percentage(filters, memoized: memoized).round * 2
      #       when 2 # Neutral
      #         res += choice.selected_percentage(filters, memoized: memoized).round * 3
      #       when 3 # Somewhat Likely
      #         res += choice.selected_percentage(filters, memoized: memoized).round * 4
      #       when 4 # Very Likely
      #         res += choice.selected_percentage(filters, memoized: memoized).round * 5
      #       end
      #     end
      #
      #     UxMetric.safe_divide(res, 500.to_f) * 100
      #   end
      #
      #   score = UxMetric.safe_divide((sentiment_score + likert_score), 2.to_f).round # average them out
      #
      #   threshold = if score >= 80
      #                 "positive"
      #               elsif score >= 60
      #                 "neutral"
      #               else
      #                 "negative"
      #               end
      #
      #   {
      #     label: threshold,
      #     threshold: threshold,
      #     score: score,
      #     likert_score: likert_score,
      #     sentiment_score: sentiment_score
      #   }
      #
      #
    # new this.Choice({ text: 'Helpful' }),
    #   new this.Choice({ text: 'Innovative' }),
    #   new this.Choice({ text: 'Simple' }),
    #   new this.Choice({ text: 'Joyful' }),
    #   new this.Choice({ text: 'Complicated' }),
    #   new this.Choice({ text: 'Confusing' }),
    #   new this.Choice({ text: 'Unnecessary' }),
    #   new this.Choice({ text: 'Uninteresting' }),
      # end
      #
  # { text: 'Very Unlikely', position: 0, branch_event: next },
  # { text: 'Somewhat Unlikely', position: 1, branch_event: next },
  # { text: 'Neutral', position: 2, branch_event: next },
  # { text: 'Somewhat Likely', position: 3, branch_event: next },
  # { text: 'Very Likely', position: 4, branch_event: next },
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
            def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
              super(msg)
            end

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
        end
      end
    end
  end
end
