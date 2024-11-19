# frozen_string_literal: true

require "glare/util"

module Glare
  module UxMetrics
    class Error < StandardError; end

    module Sentiment
      class Parser
        CHOICE_KEYS = %w[helpful innovative simple complicated confusing overwhelming annoying].freeze

        def initialize(choices:)
          @choices = choices
        end

        attr_reader :choices

        def valid?
          return false unless choices.is_a?(Hash) && choices.size

          missing_attributes = CHOICE_KEYS - choices.keys.map(&:to_s)
          return false unless missing_attributes.empty?

          return false unless choices.values.all? do |v|
            return Glare::Util.str_is_integer?(v) if v.is_a?(String)

            true if v.is_a?(Float) || v.is_a?(Integer)
          end

          true
        end

        def parse
          Result.new(result: result, threshold: threshold, label: threshold)
        end

        def result
          @result ||= choices[:helpful].to_f +
            choices[:innovative].to_f +
            choices[:simple].to_f +
            choices[:joyful].to_f -
            choices[:complicated].to_f -
            choices[:confusing].to_f -
            choices[:overwhelming].to_f -
            choices[:annoying].to_f
        end

        def threshold
          @threshold ||= if result > 1.5
                           "positive"
                         elsif result > 1.0
                           "neutral"
                         else
                           "negative"
                         end
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
      # Run Glare::UxMetrics::Feeling::Parser.new({...}) to create a parser
      class Parser
        CHOICE_KEYS = %w[very_easy somewhat_easy neutral somewhat_difficult very_difficult].freeze

        # @example Create a parser
        #   data = {
        #     very_easy: 0.4,
        #     somewhat_easy: 0.2,
        #     neutral: 0.1,
        #     somewhat_difficult: 0.05,
        #     very_difficult: 0.0
        #   }
        #   Glare::UxMetrics::Feeling::Parser.new(data)
        def initialize(choices:)
          @choices = choices
        end

        attr_reader :choices

        def valid?
          return false unless choices.is_a?(Hash) && choices.size

          missing_attributes = CHOICE_KEYS - choices.keys.map(&:to_s)
          return false unless missing_attributes.empty?

          return false unless choices.values.all? do |v|
            return Glare::Util.str_is_integer?(v) if v.is_a?(String)

            true
          end

          true
        end

        def parse
          result = choices[:very_easy].to_f +
                   choices[:somewhat_easy].to_f -
                   choices[:neutral].to_f -
                   choices[:somewhat_difficult].to_f -
                   choices[:very_difficult].to_f


          threshold = if result > 0.3
                        "positive"
                      elsif result > 0.1
                        "neutral"
                      else
                        "negative"
                      end

          label = if threshold == "positive"
                    "High Sentiment"
                  elsif threshold == "neutral"
                    "Avg Sentiment"
                  else
                    "Low Sentiment"
                  end

          Result.new(result: result, threshold: threshold, label: label)
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
      class Parser
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
          positive = sentiment["positive"]
          neutral = sentiment["neutral"]
          negative = sentiment["negative"]

          matched_very_well = choices["matched_very_well"]
          somewhat_matched = choices["somewhat_matched"]
          neutral_match = choices["neutral"]
          somewhat_didnt_match = choices["somewhat_didnt_match"]
          didnt_match_at_all = choices["didnt_match_at_all"]

          result = (matched_very_well.to_f + somewhat_matched.to_f) -
                   (neutral_match.to_f + somewhat_didnt_match.to_f + didnt_match_at_all.to_f)

          threshold = if result > 0.3
                        "positive"
                      elsif result > 0.1
                        "neutral"
                      else
                        "negative"
                      end

          label = if threshold == "positive"
                    "High Expectations"
                  elsif threshold == "neutral"
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
                        "positive"
                      elsif label == "3/5"
                        "neutral"
                      else
                        "negative"
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

    module PostTaskSatisfaction
      class Parser
        CHOICE_KEYS = %w[very_satisfied somewhat_satisfied neutral somewhat_dissatisfied very_dissatisfied].freeze

        def initialize(choices:)
          @choices = choices
        end

        attr_reader :choices

        def valid?
          return false unless choices.is_a?(Hash) && choices.size

          missing_attributes = CHOICE_KEYS - choices.keys.map(&:to_s)
          return false unless missing_attributes.empty?

          return false unless choices.values.all? do |v|
            return Glare::Util.str_is_integer?(v) if v.is_a?(String)

            true if v.is_a?(Float) || v.is_a?(Integer)
          end

          true
        end

        def parse
          result = choices[:very_satisfied].to_f +
                   choices[:somewhat_satisfied].to_f -
                   choices[:neutral].to_f -
                   choices[:somewhat_dissatisfied].to_f -
                   choices[:very_dissatisfied].to_f

         threshold = if result >= 0.7
                       "positive"
                     elsif result > 0.5
                       "neutral"
                     else
                       "negative"
                     end

          label = if threshold == "positive"
                    "High Satisfaction"
                  elsif threshold == "neutral"
                    "Average Satisfaction"
                  else
                    "Low Satisfaction"
                  end

          Result.new(result: result, threshold: threshold, label: label)
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

          def correct_data
            {
              very_satisfied: "string|integer|float",
              somewhat_satisfied: "string|integer|float",
              neutral: "string|integer|float",
              somewhat_dissatisfied: "string|integer|float",
              very_dissatisfied: "string|integer|float",
            }.to_json
          end
        end
      end
    end

    module BrandScore
      class Parser
        CHOICE_KEYS = %w[
          helpful
          clear
          engaging
          motivating
          skeptical
          confusing
          uninteresting
          overwhelming
        ].freeze

        def initialize(questions:)
          @questions = questions
        end

        attr_reader :questions

        def valid?
          return false unless questions.is_a?(Array)

          choices = questions.first
          return false unless choices.is_a?(Hash) && choices.size

          missing_attributes = CHOICE_KEYS - choices.keys.map(&:to_s)
          return false unless missing_attributes.empty?

          true
        end

        def parse
          choices = questions.first
          result = choices[:helpful].to_f +
            choices[:clear].to_f +
            choices[:engaging].to_f +
            choices[:motivating].to_f -
            choices[:skeptical].to_f -
            choices[:confusing].to_f -
            choices[:uninteresting].to_f -
            choices[:overwhelming].to_f

          sentiment_status = if result > 1.5
                               "positive"
                             elsif result > 1
                               "neutral"
                             else
                               "negative"
                             end

          sentiment_label = if sentiment_status == "positive"
                              "High Sentiment"
                            elsif sentiment_status == "neutral"
                              "Average Sentiment"
                            else
                              "Low Sentiment"
                            end

          Result.new(result: result, threshold: sentiment_status, label: sentiment_label)
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

          def correct_data
            {
              very_satisfied: "string|integer|float",
              somewhat_satisfied: "string|integer|float",
              neutral: "string|integer|float",
              somewhat_dissatisfied: "string|integer|float",
              very_dissatisfied: "string|integer|float",
            }.to_json
          end
        end
      end
    end

    module Completion
      class Parser
        def initialize(direct_success:, indirect_success:, failed:)
          @direct_success = direct_success
          @indirect_success = indirect_success
          @failed = failed
        end

        attr_reader :direct_success, :indirect_success, :failed

        def valid?
          return false unless direct_success.is_a?(Float) && indirect_success.is_a?(Float) && failed.is_a?(Float)

          true
        end

        def parse
          result = direct_success + indirect_success

          label = if result > 0.9
                    "Successful"
                  elsif result <= 90 && result >= 75
                    "Avg"
                  else
                    "Failed"
                  end

          threshold = if label == "Successful"
                        "positive"
                      elsif label == "Avg"
                        "neutral"
                      else
                        "negative"
                      end

          Result.new(result: result, threshold: threshold, label: label)
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

          def correct_data
            {
              very_satisfied: "string|integer|float",
              somewhat_satisfied: "string|integer|float",
              neutral: "string|integer|float",
              somewhat_dissatisfied: "string|integer|float",
              very_dissatisfied: "string|integer|float",
            }.to_json
          end
        end
      end
    end

    module Engagement
      class Parser
        def initialize(scores:, clicks:)
          @scores = scores
          @clicks = clicks
        end

        attr_reader :scores, :clicks

        def valid?
          return false unless scores.is_a?(Hash) && clicks.is_a?(Array) && scores.keys.size > 0 && clicks.size > 0

          true
        end

        def parse
          hotspot_1_clicks = clicks.filter {|click| click.hotspot.zero? }
          hotspot_2_clicks = clicks.filter {|click| click.hotspot == 1 }
          hotspot_3_clicks = clicks.filter {|click| click.hotspot == 3 }

          primary_score = (hotspot_1_clicks.size / clicks.size.to_f) * 100
          secondary_score = (hotspot_2_clicks.size / clicks.size.to_f) * 100
          tertiary_score = (hotspot_3_clicks.size / clicks.size.to_f) * 100

          result = primary_score + secondary_score + tertiary_score

          label = if result > 0.3
                    "High"
                  elsif result >= 0.1
                    "Avg"
                  else
                    "Low"
                  end

          threshold = if label == "High"
                        "positive"
                      elsif label == "Avg"
                        "neutral"
                      else
                        "negative"
                      end

          Result.new(result: result, threshold: threshold, label: label)
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

          def correct_data
            {
              very_satisfied: "string|integer|float",
              somewhat_satisfied: "string|integer|float",
              neutral: "string|integer|float",
              somewhat_dissatisfied: "string|integer|float",
              very_dissatisfied: "string|integer|float",
            }.to_json
          end
        end
      end
    end

    module Frequency
      class Parser
        CHOICE_KEYS = %w[very_frequently frequently occasionally rarely].freeze

        def initialize(choices:)
          @choices = choices
        end

        attr_reader :choices

        def valid?
          return false unless choices.is_a?(Hash) && choices.size

          missing_attributes = CHOICE_KEYS - choices.keys.map(&:to_s)
          return false unless missing_attributes.empty?

          return false unless choices.values.all? do |v|
            return Glare::Util.str_is_integer?(v) if v.is_a?(String)

            return true if v.is_a?(Float) || v.is_a?(Integer)

            false
          end

          true
        end

        def parse
          Result.new(result: result, threshold: threshold, label: label)
        end

        def result
          @result ||= choices[:very_frequently].to_f +
            choices[:frequently].to_f -
            choices[:occasionally].to_f -
            choices[:rarely].to_f
        end

        def threshold
          @threshold ||= if result > 0.3
                           "positive"
                         elsif result >= 0.1
                           "neutral"
                         else
                           "negative"
                         end
        end

        def label
          @label ||= if threshold == "positive"
                       "High"
                     elsif threshold == "neutral"
                       "Avg"
                     else
                       "Low"
                     end
        end

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

          def correct_data
            {
              choices: {
                very_frequently: "string|integer|float",
                frequently: "string|integer|float",
                occasionally: "string|integer|float",
                rarely: "string|integer|float",
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

      def self.default
        Result.new(result: 0.0, threshold: "", label: "")
      end

      attr_reader :result, :threshold, :label
    end

    class ClickData
      def initialize(x_pos:, y_pos:, hotspot:)
        @x_pos = x_pos
        @y_pos = y_pos
        @hotspot = hotspot
      end

      attr_reader :x_pos, :y_pos, :hotspot

      def in_hotspot?
        hotspot > -1
      end
    end
  end
end