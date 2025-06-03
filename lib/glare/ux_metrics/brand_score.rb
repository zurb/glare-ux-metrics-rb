# frozen_string_literal: true

module Glare
  module UxMetrics
    module BrandScore
      class Parser
        NPA_KEYS = %w[
          helpful
          innovative
          simple
          joyful
          complicated
          confusing
          overwhelming
          annoying
        ].freeze

        def initialize(nps_question:, market_recognition_question:, npa_question:)
          @nps_question = nps_question
          @market_recognition_question = market_recognition_question
          @npa_question = npa_question
        end

        attr_reader :nps_question, :market_recognition_question, :npa_question

        def valid?
          return false unless npa_question.is_a?(Hash) && npa_question.keys.size == 8

          return false unless nps_question.is_a?(Array) && nps_question.size == 10

          return false unless market_recognition_question.is_a?(Array)

          return false unless market_recognition_question.any? { |v| v[:selected] }

          missing_attributes = NPA_KEYS - npa_question.keys.map(&:to_s)
          return false unless missing_attributes.empty?

          true
        end

        def parse
          validate!

          result = nps_score + market_score + npa_score

          threshold = if result >= 3.0
            'positive'
          elsif result >= 2.0
            'neutral'
          else
            'negative'
          end

          label = if threshold == "positive"
                              "High"
                            elsif threshold == "neutral"
                              "Mid"
                            else
                              "Low"
                            end

          Result.new(result: result, threshold: threshold, label: label)
        end

        def breakdown
          {
            nps: nps_score,
            market_recognition: market_score,
            npa: npa_score,
          }
        end

        def nps_score
          @nps_score ||= nps_question[0..1].sum # promoters only
        end

        def market_score
          @market_score ||= market_recognition_question.select { |v| v[:selected] }[0][:percent]
        end

        def npa_score
          @npa_score ||= npa_question[:helpful].to_f +
                   npa_question[:innovative].to_f +
                   npa_question[:simple].to_f +
                   npa_question[:joyful].to_f -
                   npa_question[:complicated].to_f -
                   npa_question[:confusing].to_f -
                   npa_question[:overwhelming].to_f -
                   npa_question[:annoying].to_f
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
              nps_question: [
                0.1, # highest
                0.2,
                0.1,
                0.05,
                0.09,
                0.05,
                0.1,
                0.01,
                0.02,
                0.02 # lowest
              ],
              npa_question: {
                helpful: "string|integer|float",
                innovative: "string|integer|float",
                simple: "string|integer|float",
                joyful: "string|integer|float",
                complicated: "string|integer|float",
                confusing: "string|integer|float",
                overwhelming: "string|integer|float",
                annoying: "string|integer|float",
              },
              market_recognition_question: [
                { selected: false, percent: 0.5 },
                { selected: true, percent: 0.2 },
                { selected: false, percent: 0.1 },
                { selected: false, percent: 0.05 },
                { selected: false, percent: 0.2 },
                { selected: false, percent: 0.05 },
                { selected: false, percent: 0.05 },
              ]
            }.to_json
          end
        end

        private

        def data
          @data ||= {
            nps_question: nps_question,
            market_recognition_question: market_recognition_question,
            npa_question: npa_question
          }
        end

        def validate!
          raise InvalidDataError, data unless valid?
        end
      end
    end
  end
end

