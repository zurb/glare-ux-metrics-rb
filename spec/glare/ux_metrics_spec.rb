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

    it "validates valid desirability data" do
      data = Glare::UxMetrics::Desirability::Parser.new(
        questions: desirability_data
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid desirability data" do
      data = Glare::UxMetrics::Desirability::Parser.new(questions: [{ bla: "hi" }])
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Desirability::Parser.new(
        questions: desirability_data,
      ).parse(question_index: 1)
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
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
        {
          helpful: 0.1,
          clear: 0.1,
          engaging: 0.1,
          motivating: 0.1,
          skeptical: 0.1,
          confusing: 0.1,
          uninteresting: 0.1,
          overwhelming: 0.1
        },
        [0.2, 0.3, 0.4, 0.4, 0.2, 0.2, 0.2, 0.2, 0.0],
      ]
    end

    it "validates valid brand score data" do
      data = Glare::UxMetrics::BrandScore::Parser.new(
        questions: brand_score_data,
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid brand score data" do
      data = Glare::UxMetrics::BrandScore::Parser.new(questions: [{ hi: "yooo" }])
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::BrandScore::Parser.new(
        questions: brand_score_data,
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
