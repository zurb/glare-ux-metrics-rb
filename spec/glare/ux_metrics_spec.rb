# frozen_string_literal: true

require_relative "../../lib/glare/ux_metrics"

RSpec.describe Glare::UxMetrics do
  describe Glare::UxMetrics::Sentiment do
    let(:sentiment_data) do
      {
        helpful: 0.1,
        innovative: 0.1,
        simple: 0.1,
        joyful: 0.1,
        complicated: 0.1,
        confusing: 0.1,
        overwhelming: 0.1,
        annoying: 0.1,
      }
    end

    it "validates valid sentiment data" do
      data = Glare::UxMetrics::Sentiment::Parser.new(choices: sentiment_data)
      expect(data.valid?).to eq(true)
    end

    it "invalidates non float/integer-like values" do
      data = Glare::UxMetrics::Sentiment::Parser.new(choices: {
        helpful: 0.1,
        innovative: 0.1,
        simple: 0.1,
        joyful: 0.1,
        complicated: 0.1,
        confusing: 0.1,
        overwhelming: 0.1,
        annoying: "hi"
      })
      expect(data.valid?).to eq(false)
    end

    it "invalidates invalid sentiment data" do
      data = Glare::UxMetrics::Sentiment::Parser.new(choices: { helpful: 1 })
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Sentiment::Parser.new(choices: sentiment_data).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end
  end

  describe Glare::UxMetrics::Feeling do
    let(:feeling_data) do
      {
        anticipation: 0.4,
        surprise: 0.2,
        joy: 0.1,
        trust: 0.05,
        anger: 0.02,
        disgust: 0.0,
        sadness: 0.0,
        fear: 0.0
      }
    end

    it "validates valid feeling data" do
      data = Glare::UxMetrics::Feeling::Parser.new(choices: feeling_data)
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid feeling data" do
      data = Glare::UxMetrics::Feeling::Parser.new(choices: { helpful: 1 })
      expect(data.valid?).to eq(false)
    end

    it "invalidates non float/integer-like values" do
      data = Glare::UxMetrics::Feeling::Parser.new(choices: {
        very_easy: 0.3,
        somewhat_easy: 0.4,
        neutral: 0.1,
        somewhat_difficult: 0.1,
        very_difficult: "hi"
      })
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Feeling::Parser.new(choices: feeling_data).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end
  end

  describe Glare::UxMetrics::Expectations do
    let(:expectations_data) do
      {
        sentiment: {
          positive: 0.5,
          neutral: 0.3,
          negative: 0.2
        },
        choices: {
          matched_very_well: 0.3,
          somewhat_matched: 0.4,
          neutral: 0.1,
          somewhat_didnt_match: 0.1,
          didnt_match_at_all: 0.1,
        }
      }
    end

    it "validates valid expectations data" do
      data = Glare::UxMetrics::Expectations::Parser.new(
        choices: expectations_data[:choices],
        sentiment: expectations_data[:sentiment]
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid expectations data" do
      data = Glare::UxMetrics::Expectations::Parser.new(choices: { helpful: 1 }, sentiment: { bla: "hi" })
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Expectations::Parser.new(
        choices: expectations_data[:choices],
        sentiment: expectations_data[:sentiment]
      ).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end
  end

  describe Glare::UxMetrics::Desirability do
    context "Parser Versioning" do
      it "defaults to V2::Parser" do
        expect(Glare::UxMetrics::Desirability.default_parser_version).to eq(Glare::UxMetrics::Desirability::V2::Parser)
      end
    end
  end

  describe Glare::UxMetrics::Desirability::V1 do
    let(:desirability_data_section) do
      {
        very_interested: 0.3,
        moderately_interested: 0.4,
        slightly_interested: 0.2,
        not_interested: 0.1
      }
    end

    let(:desirability_data) do
      [
        desirability_data_section,
        desirability_data_section,
        desirability_data_section,
        desirability_data_section,
      ]
    end

    let(:desirability_data_as_nps_section) do
      [0.20, 0.30, 0.30, 0.5, 0.05, 0, 0, 0, 0.1, 0.05]
    end

    let(:desirability_data_as_nps_section_2) do
      [0.20, 0.30, 0.30, 0.50, 0.05, 0, 0, 0, 0.1, 0.05]
    end

    let(:desirability_data_as_nps_section_3) do
      [0.20, 0.30, 0.30, 0.50, 0.05, 0, 0, 0, 0.1, 0.05]
    end

    let(:desirability_data_as_nps_section_4) do
      [0.3, 0.3, 0.3, 0.5, 0.05, 0, 0, 0, 0.1, 0.1]
    end

    let(:desirability_data_as_nps_section_5) do
      [0.3, 0.3, 0.3, 0.5, 0.05, 0, 0, 0, 0.1, 0.1]
    end

    let(:desirability_data_as_nps_section_6) do
      [0, 0, 0.3, 0.5, 0.05, 0, 0, 0, 0.1, 0.1]
    end

    let(:desirability_data_as_nps_section_7) do
      [0.5, 0.5, 0, 0, 0, 0, 0, 0, 0, 0]
    end

    let(:desirability_data_as_nps) do
      [
        desirability_data_as_nps_section,
        desirability_data_as_nps_section_2,
        desirability_data_as_nps_section_3,
        desirability_data_as_nps_section_4,
        desirability_data_as_nps_section_5,
        desirability_data_as_nps_section_6,
        desirability_data_as_nps_section_7,
      ]
    end

    context "Multiple Choice" do
      it "validates valid desirability data" do
        data = Glare::UxMetrics::Desirability::V1::Parser.new(
          questions: desirability_data
        )
        expect(data.valid?).to eq(true)
      end

      it "invalidates invalid desirability data" do
        data = Glare::UxMetrics::Desirability::V1::Parser.new(questions: [{ bla: "hi" }])
        expect(data.valid?).to eq(false)
      end

      it "returns valid data" do
        data = Glare::UxMetrics::Desirability::V1::Parser.new(
          questions: desirability_data
        ).parse(question_index: 1)
        expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
      end
    end

    context "NPS" do
      it "validates valid desirability data" do
        data = Glare::UxMetrics::Desirability::V1::Parser.new(
          questions: desirability_data_as_nps
        )
        expect(data.valid?).to eq(true)
      end

      it "invalidates invalid desirability data" do
        data = Glare::UxMetrics::Desirability::V1::Parser.new(questions: [[0, 2]])
        expect(data.valid?).to eq(false)
      end

      it "returns valid data" do
        data = Glare::UxMetrics::Desirability::V1::Parser.new(
          questions: desirability_data_as_nps
        ).parse(question_index: 1)
        expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
      end

      it "uses the same label if the score is the same" do
        data = Glare::UxMetrics::Desirability::V1::Parser.new(
          questions: desirability_data_as_nps
        ).parse(question_index: 0)
        data2 = Glare::UxMetrics::Desirability::V1::Parser.new(
          questions: desirability_data_as_nps
        ).parse(question_index: 1)

        expect(data.label == data2.label).to eq(true)

        data3 = Glare::UxMetrics::Desirability::V1::Parser.new(
          questions: desirability_data_as_nps
        ).parse(question_index: 3)
        data4 = Glare::UxMetrics::Desirability::V1::Parser.new(
          questions: desirability_data_as_nps
        ).parse(question_index: 4)

        expect(data3.label == data4.label).to eq(true)

        data5 = Glare::UxMetrics::Desirability::V1::Parser.new(
          questions: desirability_data_as_nps
        ).parse(question_index: 2)
        data6 = Glare::UxMetrics::Desirability::V1::Parser.new(
          questions: desirability_data_as_nps
        ).parse(question_index: 3)

        expect(data6.label == data5.label).to eq(false)
      end

      it "returns 5/5 if at 100 nps" do
        data = Glare::UxMetrics::Desirability::V1::Parser.new(
          questions: desirability_data_as_nps
        ).parse(question_index: 6)

        expect(data.label).to eq("5/5")
      end
    end
  end

  describe Glare::UxMetrics::Desirability::V2 do
    let(:sentiment_question) do
      {
        helpful: 0.3,
        innovative: 0.2,
        simple: 0.2,
        joyful: 0.1,
        complicated: 0.05,
        confusing: 0.05,
        unnecessary: 0.05,
        uninteresting: 0.05
      }
    end

    let(:likert_question) do
      {
        very_unlikely: 0.1,
        somewhat_unlikely: 0.1,
        neutral: 0.2,
        somewhat_likely: 0.3,
        very_likely: 0.3
      }
    end

    let(:desirability_data) do
      [
        sentiment_question,
        likert_question
      ]
    end

    context "Validation" do
      it "validates valid desirability data" do
        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: desirability_data
        )
        expect(data.valid?).to eq(true)
      end

      it "invalidates when missing sentiment question" do
        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [likert_question]
        )
        expect(data.valid?).to eq(false)
      end

      it "invalidates when missing likert question" do
        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [sentiment_question]
        )
        expect(data.valid?).to eq(false)
      end

      it "invalidates when sentiment question is missing keys" do
        invalid_sentiment = sentiment_question.dup
        invalid_sentiment.delete(:helpful)

        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [invalid_sentiment, likert_question]
        )
        expect(data.valid?).to eq(false)
      end

      it "invalidates when likert question is missing keys" do
        invalid_likert = likert_question.dup
        invalid_likert.delete(:very_likely)

        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [sentiment_question, invalid_likert]
        )
        expect(data.valid?).to eq(false)
      end

      it "invalidates non float/integer-like values in sentiment question" do
        invalid_sentiment = sentiment_question.dup
        invalid_sentiment[:helpful] = "not a number"

        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [invalid_sentiment, likert_question]
        )
        expect(data.valid?).to eq(false)
      end

      it "invalidates non float/integer-like values in likert question" do
        invalid_likert = likert_question.dup
        invalid_likert[:very_likely] = "not a number"

        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [sentiment_question, invalid_likert]
        )
        expect(data.valid?).to eq(false)
      end
    end

    context "Parsing" do
      it "returns valid data" do
        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: desirability_data
        ).parse
        expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
      end

      it "calculates sentiment score correctly" do
        parser = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: desirability_data
        )

        # Calculate expected sentiment score
        positive_values = sentiment_question[:helpful] + sentiment_question[:innovative] +
                          sentiment_question[:simple] + sentiment_question[:joyful]
        negative_values = sentiment_question[:complicated] + sentiment_question[:confusing] +
                          sentiment_question[:unnecessary] + sentiment_question[:uninteresting]
        expected_score = positive_values / (positive_values + negative_values)

        expect(parser.calculate_sentiment_question(sentiment_question)).to be_within(0.001).of(expected_score)
      end

      it "calculates likert score correctly" do
        parser = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: desirability_data
        )

        # Calculate expected likert score
        expected_score = (
          likert_question[:very_unlikely] * 1 +
          likert_question[:somewhat_unlikely] * 2 +
          likert_question[:neutral] * 3 +
          likert_question[:somewhat_likely] * 4 +
          likert_question[:very_likely] * 5
        ) / 5.0

        expect(parser.calculate_likert_question(likert_question)).to be_within(0.001).of(expected_score)
      end

      it "assigns 'Good' label for positive threshold" do
        # Create data that will result in a high score
        high_sentiment = {
          helpful: 0.7,
          innovative: 0.6,
          simple: 0.8,
          joyful: 0.7,
          complicated: 0.05,
          confusing: 0.05,
          unnecessary: 0.05,
          uninteresting: 0.05
        }

        high_likert = {
          very_unlikely: 0.05,
          somewhat_unlikely: 0.05,
          neutral: 0.1,
          somewhat_likely: 0.3,
          very_likely: 0.5
        }

        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [high_sentiment, high_likert]
        ).parse

        expect(data.threshold).to eq("positive")
        expect(data.label).to eq("Good")
      end

      it "assigns 'Neutral' label for neutral threshold" do
        # Create data that will result in a medium score
        medium_sentiment = {
          helpful: 0.4,
          innovative: 0.3,
          simple: 0.3,
          joyful: 0.2,
          complicated: 0.2,
          confusing: 0.2,
          unnecessary: 0.2,
          uninteresting: 0.2
        }

        medium_likert = {
          very_unlikely: 0.1,
          somewhat_unlikely: 0.2,
          neutral: 0.4,
          somewhat_likely: 0.2,
          very_likely: 0.1
        }

        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [medium_sentiment, medium_likert]
        ).parse

        expect(data.threshold).to eq("neutral")
        expect(data.label).to eq("Neutral")
      end

      it "assigns 'Bad' label for negative threshold" do
        # Create data that will result in a low score
        low_sentiment = {
          helpful: 0.1,
          innovative: 0.1,
          simple: 0.1,
          joyful: 0.1,
          complicated: 0.3,
          confusing: 0.3,
          unnecessary: 0.5,
          uninteresting: 0.5
        }

        low_likert = {
          very_unlikely: 0.5,
          somewhat_unlikely: 0.3,
          neutral: 0.1,
          somewhat_likely: 0.05,
          very_likely: 0.05
        }

        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [low_sentiment, low_likert]
        ).parse

        expect(data.threshold).to eq("negative")
        expect(data.label).to eq("Bad")
      end
    end

    context "Breakdown" do
      it "returns two breakdowns" do
        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [sentiment_question, likert_question]
        )
       expect(data.breakdown.size).to eq(2)
      end

      it "returns a sentiment and likert breakdown" do
        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [sentiment_question, likert_question]
        )
        expect(data.breakdown.keys.sort).to eq([:sentiment_score, :likert_score].sort)
      end

      it "sentiment is between 0.0 and 1.0" do
        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [sentiment_question, likert_question]
        )
        expect(data.breakdown[:sentiment_score]).to be_between(0.0, 1.0)
      end

      it "likert is between 0.0 and 1.0" do
        data = Glare::UxMetrics::Desirability::V2::Parser.new(
          questions: [sentiment_question, likert_question]
        )
        expect(data.breakdown[:likert_score]).to be_between(0.0, 1.0)
      end
    end
  end

  describe Glare::UxMetrics::PostTaskSatisfaction do
    let(:post_task_satisfaction_data) do
      {
        very_satisfied: 0.1,
        somewhat_satisfied: 0.1,
        neutral: 0.1,
        somewhat_dissatisfied: 0.1,
        very_dissatisfied: 0.1,
      }
    end

    it "validates valid post-task satisfaction data" do
      data = Glare::UxMetrics::PostTaskSatisfaction::Parser.new(
        choices: post_task_satisfaction_data,
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid post-task satisfaction data" do
      data = Glare::UxMetrics::PostTaskSatisfaction::Parser.new(choices: { ha: "bla" })
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::PostTaskSatisfaction::Parser.new(
        choices: post_task_satisfaction_data,
      ).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end
  end

  describe Glare::UxMetrics::BrandScore do
    let(:brand_score_data) do
      [
        [0.2, 0.3, 0.4, 0.4, 0.2, 0.2, 0.2, 0.2, 0.0, 0.2],
        [
          { selected: true, percent: 0.1 },
          { selected: false, percent: 0.1 },
          { selected: false, percent: 0.1 },
          { selected: false, percent: 0.1 },
          { selected: false, percent: 0.1 },
          { selected: false, percent: 0.1 },
          { selected: false, percent: 0.1 },
          { selected: false, percent: 0.1 }
        ],
        {
          helpful: 0.1,
          innovative: 0.1,
          simple: 0.1,
          joyful: 0.1,
          complicated: 0.1,
          confusing: 0.1,
          overwhelming: 0.1,
          annoying: 0.1,
        },
      ]
    end

    it "validates valid brand score data" do
      data = Glare::UxMetrics::BrandScore::Parser.new(
        nps_question: brand_score_data[0],
        market_recognition_question: brand_score_data[1],
        npa_question: brand_score_data[2],
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid brand score data" do
      data = Glare::UxMetrics::BrandScore::Parser.new(
        nps_question: [],
        npa_question: {},
        market_recognition_question: {},
      )
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::BrandScore::Parser.new(
        nps_question: brand_score_data[0],
        market_recognition_question: brand_score_data[1],
        npa_question: brand_score_data[2],
      ).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end
  end

  describe Glare::UxMetrics::Completion do
    let(:completion_data) do
      {
        direct_success: 0.5,
        indirect_success: 0.3,
        failed: 0.2
      }
    end

    it "validates valid completion data" do
      data = Glare::UxMetrics::Completion::Parser.new(
        direct_success: completion_data[:direct_success],
        indirect_success: completion_data[:indirect_success],
        failed: completion_data[:failed],
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid completion data" do
      data = Glare::UxMetrics::Completion::Parser.new(direct_success: "yooo", indirect_success: "yooo", failed: "yooo")
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Completion::Parser.new(
        direct_success: completion_data[:direct_success],
        indirect_success: completion_data[:indirect_success],
        failed: completion_data[:failed],
      ).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end
  end

  describe Glare::UxMetrics::Engagement do
    let(:data) do
      {
        scores: {
          direct_success: 0.5,
          indirect_success: 0.3,
          failed: 0.2
        },
        clicks: [
          Glare::UxMetrics::ClickData.new(x_pos: 0.2, y_pos: 0.2, hotspot: 0),
          Glare::UxMetrics::ClickData.new(x_pos: 0.2, y_pos: 0.2, hotspot: 0),
          Glare::UxMetrics::ClickData.new(x_pos: 0.2, y_pos: 0.2, hotspot: 1),
          Glare::UxMetrics::ClickData.new(x_pos: 0.2, y_pos: 0.2, hotspot: 1),
          Glare::UxMetrics::ClickData.new(x_pos: 0.2, y_pos: 0.2, hotspot: 2),
          Glare::UxMetrics::ClickData.new(x_pos: 0.2, y_pos: 0.2, hotspot: 2),
          Glare::UxMetrics::ClickData.new(x_pos: 0.2, y_pos: 0.2, hotspot: 0),
          Glare::UxMetrics::ClickData.new(x_pos: 0.2, y_pos: 0.2, hotspot: 0),
          Glare::UxMetrics::ClickData.new(x_pos: 0.2, y_pos: 0.2, hotspot: 0),
          Glare::UxMetrics::ClickData.new(x_pos: 0.2, y_pos: 0.2, hotspot: 0),
          Glare::UxMetrics::ClickData.new(x_pos: 0.2, y_pos: 0.2, hotspot: 0),
          Glare::UxMetrics::ClickData.new(x_pos: 0.2, y_pos: 0.2, hotspot: 0),
        ]
      }
    end

    it "validates valid engagement data" do
      parser = Glare::UxMetrics::Engagement::Parser.new(
        scores: data[:scores],
        clicks: data[:clicks]
      )
      expect(parser.valid?).to eq(true)
    end

    it "invalidates invalid engagement data" do
      parser = Glare::UxMetrics::Engagement::Parser.new(scores: { sup: "ooooo" }, clicks: [])
      expect(parser.valid?).to eq(false)
    end

    it "returns valid data" do
      parser = Glare::UxMetrics::Engagement::Parser.new(
        scores: data[:scores],
        clicks: data[:clicks]
      ).parse
      expect(parser.result.is_a?(Float) && parser.label.is_a?(String) && parser.threshold.is_a?(String)).to eq(true)
    end
  end

  describe Glare::UxMetrics::Result do
    it "returns a valid default" do
      result = Glare::UxMetrics::Result.default
      expect(result).to be_a(Glare::UxMetrics::Result)
      expect(result.result).to eq(0.0)
      expect(result.threshold.empty?).to eq(true)
      expect(result.label.empty?).to eq(true)
    end
  end
end
