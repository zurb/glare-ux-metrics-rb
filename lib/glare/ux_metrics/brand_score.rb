# frozen_string_literal: true

module Glare
  module UxMetrics
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
  end
end

