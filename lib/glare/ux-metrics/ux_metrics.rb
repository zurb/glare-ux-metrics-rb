# frozen_string_literal: true

module Glare
  module UxMetrics
    class Error < StandardError; end

    module Sentiment
      class Data
        CHOICE_KEYS = %w[helpful innovative simple complicated confusing overwhelming annoying].freeze

        def initialize(choices:)
          @choices = choices
        end

        attr_reader :choices

        def valid?
          if choices.is_a?(Hash) && choices.size
            missing_attributes = CHOICE_KEYS - choices.keys.map(&:to_s)
            return true if missing_attributes.empty?
          end

          false
        end

        def parse
          result = choices[:helpful].to_f +
            choices[:innovative].to_f +
            choices[:simple].to_f +
            choices[:joyful].to_f -
            choices[:complicated].to_f -
            choices[:confusing].to_f -
            choices[:overwhelming].to_f -
            choices[:annoying].to_f

          threshold = if result > 1.5
                        'positive'
                      elsif result > 1.0
                        'neutral'
                      else
                        'negative'
                      end

          Result.new(result: result, threshold: threshold, label: threshold)
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

          def correct_data
            {
              choices: {
                helpful: "string|integer|float",
                innovative: "string|integer|float",
                simple: "string|integer|float",
                joyful: "string|integer|float",
                complicated: "string|integer|float",
                confusing: "string|integer|float",
                overwhelming: "string|integer|float",
                annoying: "string|integer|float",
              }
            }.to_json
          end
        end
      end
    end

    module Feeling
      class Data
        CHOICE_KEYS = %w[very_easy somewhat_easy neutral somewhat_difficult very_difficult].freeze

        def initialize(choices:)
          @choices = choices
        end

        attr_reader :choices

        def valid?
          if choices.is_a?(Hash) && choices.size
            missing_attributes = CHOICE_KEYS - choices.keys.map(&:to_s)
            return true if missing_attributes.empty?
          end

          false
        end

        def parse
          result = choices[:very_easy].to_f +
            choices[:somewhat_easy].to_f -
            choices[:neutral].to_f -
            choices[:somewhat_difficult].to_f -
            choices[:very_difficult].to_f

          threshold = if result > 0.3
                        'positive'
                      elsif result > 0.1
                        'neutral'
                      else
                        'negative'
                      end

          Result.new(result: result, threshold: threshold, label: threshold)
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

          def correct_data
            {
              choices: {
                very_easy: "string|integer|float",
                somewhat_easy: "string|integer|float",
                neutral: "string|integer|float",
                somewhat_difficult: "string|integer|float",
                very_difficult: "string|integer|float"
              }
            }.to_json
          end
        end
      end
    end

    module Expectations
      class Data
        CHOICE_KEYS = %w[matched_very_well somewhat_matched neutral somewhat_didnt_match didnt_match_at_all].freeze
        SENTIMENT_KEYS = %w[positive neutral negative].freeze
        def initialize(choices:, sentiment:)
          @choices = choices
          @sentiment = sentiment
        end

        attr_reader :choices, :sentiment

        def valid?

          if choices.is_a?(Hash) && choices.size
            missing_attributes = CHOICE_KEYS - choices.keys.map(&:to_s)
            return false unless missing_attributes.empty?
          end

          if sentiment.is_a?(Hash) && sentiment.size
            missing_attributes = SENTIMENT_KEYS - sentiment.keys.map(&:to_s)
            return true if missing_attributes.empty?
          end

          false
        end

        def parse
          positive = sentiment['positive']
          neutral = sentiment['neutral']
          negative = sentiment['negative']

          matched_very_well = choices['matched_very_well']
          somewhat_matched = choices['somewhat_matched']
          neutral_match = choices['neutral']
          somewhat_didnt_match = choices['somewhat_didnt_match']
          didnt_match_at_all = choices['didnt_match_at_all']

          result = (matched_very_well.to_f + somewhat_matched.to_f) -
            (neutral_match.to_f + somewhat_didnt_match.to_f + didnt_match_at_all.to_f)

          threshold = if result > 0.3
                        'positive'
                      elsif result > 0.1
                        'neutral'
                      else
                        'negative'
                      end

          label = if threshold == 'positive'
                    "High Expectations"
                  elsif threshold == 'neutral'
                    "Met Expectations"
                  else
                    "Failed Expectations"
                  end

          Result.new(result: result, threshold: threshold, label: label)
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

    module Desirability
      class Data
        CHOICE_KEYS = %w[very_interested moderately_interested slightly_interested not_interested].freeze

        def initialize(questions:)
          @questions = questions
        end

        attr_reader :questions

        def valid?

          if questions.is_a?(Array) && questions.size
            is_invalid = false
            questions.all? do |question|
              missing_attributes = CHOICE_KEYS - question.keys.map(&:to_s)
              is_invalid = true unless missing_attributes.empty?
            end
            return true unless is_invalid
          end

          false
        end

        def parse(question_index:)
          scored_questions = []
          questions.each_with_index do |question, index|
            scored_questions.push({
              score: calculate_question(question),
              question: question,
              selected: index == question_index
            })
          end

          ordered_scored_questions = scored_questions.sort_by do |question|
            question[:score]
          end

          ordered_scored_questions.each_with_index do |question, index|
            # append :fraction property [whole number]/5

            numerator = (index * ordered_scored_questions.length - 1).round
            denominator = 5

            question[:fraction] = "#{numerator}/#{denominator}"
          end

          selected_scored_question = ordered_scored_questions.find do |question|
            question[:selected]
          end

          result = selected_scored_question[:score]

          label = selected_scored_question[:fraction]

          threshold = if %w[5/5 4/5].include? label
                        'positive'
                      elsif label == "3/5"
                        'neutral'
                      else
                        'negative'
                      end

          Result.new(result: result, threshold: threshold, label: label)
        end

        def calculate_question(question)
          question[:very_interested].to_f + question[:moderately_interested].to_f - question[:slightly_interested].to_f - question[:not_interested].to_f
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

    class Result
      def initialize(result:, threshold:, label:)
        @result = result
        @threshold = threshold
        @label = label
      end

      attr_reader :result, :threshold, :label

    end
  end
end
