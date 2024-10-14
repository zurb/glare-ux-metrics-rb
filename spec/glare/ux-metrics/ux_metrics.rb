# frozen_string_literal: true

require_relative "../../../lib/glare/ux-metrics/ux_metrics.rb"

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
      data = Glare::UxMetrics::Sentiment::Data.new(choices: sentiment_data)
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid sentiment data" do
      data = Glare::UxMetrics::Sentiment::Data.new(choices: { helpful: 1 })
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Sentiment::Data.new(choices: sentiment_data).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end
  end

  describe Glare::UxMetrics::Feeling do
    let(:feeling_data) do
      {
        very_easy: 0.3,
        somewhat_easy: 0.4,
        neutral: 0.1,
        somewhat_difficult: 0.1,
        very_difficult: 0.1
      }
    end

    it "validates valid feeling data" do
      data = Glare::UxMetrics::Feeling::Data.new(choices: feeling_data)
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid feeling data" do
      data = Glare::UxMetrics::Feeling::Data.new(choices: { helpful: 1 })
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Feeling::Data.new(choices: feeling_data).parse
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
      data = Glare::UxMetrics::Expectations::Data.new(
        choices: expectations_data[:choices],
        sentiment: expectations_data[:sentiment]
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid expectations data" do
      data = Glare::UxMetrics::Expectations::Data.new(choices: { helpful: 1 }, sentiment: { bla: "hi" })
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Expectations::Data.new(
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
      data = Glare::UxMetrics::Desirability::Data.new(
        questions: desirability_data
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid desirability data" do
      data = Glare::UxMetrics::Desirability::Data.new(questions: [{ bla: "hi" }])
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Desirability::Data.new(
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
      data = Glare::UxMetrics::PostTaskSatisfaction::Data.new(
        choices: post_task_satisfaction_data,
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid post-task satisfaction data" do
      data = Glare::UxMetrics::PostTaskSatisfaction::Data.new(choices: { ha: "bla" })
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::PostTaskSatisfaction::Data.new(
        choices: post_task_satisfaction_data,
      ).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end
  end
end
