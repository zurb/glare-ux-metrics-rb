# frozen_string_literal: true

module Glare
  module UxMetrics
    module BrandScore

      
  #   nps_section = sections.where(type: 'NpsSection').last
  #   market_recognition_section = sections.where(type: 'MultipleChoiceSection').first
  #   npa_section = sections.where(type: 'MultipleChoiceSection').last
  #
  #   # Calculate the three components: Market Recognition, NPA, and NPS
  #   market_recognition_percentage = (market_recognition_section.present? ? calculate_market_recognition(market_recognition_section) : 0).round
  #   npa_percentage = (npa_section.present? ? calculate_npa(npa_section) : 0).round
  #   nps_percentage = (nps_section.present? ? calculate_nps(nps_section, promoter_only: true) : 0).round
  #
  #   # Sum up the three components
  #   total_score = market_recognition_percentage + npa_percentage + nps_percentage
  #
  #   # Determine the threshold based on the total score
  #   threshold = determine_brand_score_threshold(total_score)
  #   label = determine_brand_score_label(total_score)
  #
  #   {
  #     label: label,
  #     threshold: threshold,
  #     market_recognition: "#{market_recognition_percentage}%",
  #     npa: "#{npa_percentage}%",
  #     nps: "#{nps_percentage}%",
  #     score: total_score
  #   }
  # end
  #
  # def calculate_market_recognition(section)
  #   return 0 unless section&.variations&.any? && section.variations.first.choices&.any?
  #
  #   brand_choice = section.variations.first.choices.where(is_brand_score_selected: true).first
  #
  #   brand_choice&.selected_percentage(@filters) || 0
  # end
  #
  # # Calculate the Net Positive Alignment (NPA) based on impressions
  # def calculate_npa(section)
  #   section&.net_positive_alignment(@filters, memoized: @memoized) || 0
  # end
  #
  # # Calculate the Net Promoter Score (NPS) based on a 0-10 scale question
  # def calculate_nps(section, promoter_only: false)
  #   section&.score(@filters, memoized: @memoized, promoter_only: promoter_only) || 0
  # end
  #
  # # Determine the brand score threshold based on the total score
  # def determine_brand_score_label(total_score)
  #   threshold = determine_brand_score_threshold(total_score)
  #   if threshold == 'positive'
  #     'High'
  #   elsif threshold == 'neutral'
  #     'Mid'
  #   else
  #     'Low'
  #   end
  # end
  #
  # def determine_brand_score_threshold(total_score)
  #   return @determine_brand_score_threshold if @memoized && @determine_brand_score_threshold.present?
  #
  #   @determine_brand_score_threshold = if total_score >= 300
  #     'positive'
  #   elsif total_score >= 200
  #     'neutral'
  #   else
  #     'negative'
  #   end
  # end
  #
    # new this.Choice({ text: 'Helpful' }),
    #   new this.Choice({ text: 'Innovative' }),
    #   new this.Choice({ text: 'Simple' }),
    #   new this.Choice({ text: 'Joyful' }),
    #   new this.Choice({ text: 'Complicated' }),
    #   new this.Choice({ text: 'Confusing' }),
    #   new this.Choice({ text: 'Overwhelming' }),
    #   new this.Choice({ text: 'Annoying' }),

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

          missing_attributes = NPA_KEYS - npa_question.keys.map(&:to_s)
          return false unless missing_attributes.empty?

          true
        end

        def parse
          npa = npa_question[:helpful].to_f +
                   npa_question[:innovative].to_f +
                   npa_question[:simple].to_f +
                   npa_question[:joyful].to_f -
                   npa_question[:complicated].to_f -
                   npa_question[:confusing].to_f -
                   npa_question[:overwhelming].to_f -
                   npa_question[:annoying].to_f

          market = market_recognition_question.select { |v| v[:selected] }.first[:percent]

          nps = nps_question[0..1].sum # promoters only

          result = nps + market + npa

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

        class InvalidDataError < Error
          def initialize(msg = "Data not valid. Correct data format is: \n\n#{correct_data}")
            super(msg)
          end

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
      end
    end
  end
end

