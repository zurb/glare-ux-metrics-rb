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
        failed_expectations: 0.1,
        fell_short_of_expectations: 0.1,
        neutral: 0.1,
        met_expectations: 0.3,
        exceeded_expectations: 0.4
      }
    end

    it "validates valid expectations data" do
      data = Glare::UxMetrics::Expectations::Parser.new(
        choices: expectations_data
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid expectations data" do
      data = Glare::UxMetrics::Expectations::Parser.new(choices: { helpful: 1 })
      expect(data.valid?).to eq(false)
    end

    it "invalidates when missing required keys" do
      incomplete_data = {
        failed_expectations: 0.1,
        fell_short_of_expectations: 0.1,
        neutral: 0.1,
        met_expectations: 0.3
        # missing exceeded_expectations
      }
      data = Glare::UxMetrics::Expectations::Parser.new(choices: incomplete_data)
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Expectations::Parser.new(
        choices: expectations_data
      ).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end

    it "calculates result correctly" do
      data = Glare::UxMetrics::Expectations::Parser.new(
        choices: expectations_data
      )
      
      # Calculate expected result
      positive_impressions = expectations_data[:exceeded_expectations] + 
                             expectations_data[:met_expectations]
      neutral_impressions = expectations_data[:neutral]
      negative_impressions = expectations_data[:failed_expectations] + 
                             expectations_data[:fell_short_of_expectations]
      
      expected_result = positive_impressions - (neutral_impressions + negative_impressions)
      
      expect(data.result).to be_within(0.001).of(expected_result)
    end

    it "assigns 'High' label for result > 0.3" do
      high_score_data = {
        failed_expectations: 0.05,
        fell_short_of_expectations: 0.05,
        neutral: 0.1,
        met_expectations: 0.3,
        exceeded_expectations: 0.5
      }
      
      data = Glare::UxMetrics::Expectations::Parser.new(
        choices: high_score_data
      ).parse
      
      expect(data.threshold).to eq("positive")
      expect(data.label).to eq("High")
    end

    it "assigns 'Met' label for result > 0.1 and <= 0.3" do
      medium_score_data = {
        failed_expectations: 0.1,
        fell_short_of_expectations: 0.1,
        neutral: 0.2,
        met_expectations: 0.3,
        exceeded_expectations: 0.3
      }
      
      data = Glare::UxMetrics::Expectations::Parser.new(
        choices: medium_score_data
      ).parse
      
      expect(data.threshold).to eq("neutral")
      expect(data.label).to eq("Met")
    end

    it "assigns 'Failed' label for result <= 0.1" do
      low_score_data = {
        failed_expectations: 0.3,
        fell_short_of_expectations: 0.3,
        neutral: 0.2,
        met_expectations: 0.1,
        exceeded_expectations: 0.1
      }
      
      data = Glare::UxMetrics::Expectations::Parser.new(
        choices: low_score_data
      ).parse
      
      expect(data.threshold).to eq("negative")
      expect(data.label).to eq("Failed")
    end
  end

  describe Glare::UxMetrics::Satisfaction do
    let(:satisfaction_data) do
      {
        very_dissatisfied: 0.1,
        somewhat_dissatisfied: 0.1,
        neutral: 0.1,
        somewhat_satisfied: 0.3,
        very_satisfied: 0.4
      }
    end

    it "validates valid satisfaction data" do
      data = Glare::UxMetrics::Satisfaction::Parser.new(
        choices: satisfaction_data
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid satisfaction data" do
      data = Glare::UxMetrics::Satisfaction::Parser.new(choices: { helpful: 1 })
      expect(data.valid?).to eq(false)
    end

    it "invalidates when missing required keys" do
      incomplete_data = {
        very_dissatisfied: 0.1,
        somewhat_dissatisfied: 0.1,
        neutral: 0.1,
        somewhat_satisfied: 0.3
        # missing very_satisfied
      }
      data = Glare::UxMetrics::Satisfaction::Parser.new(choices: incomplete_data)
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Satisfaction::Parser.new(
        choices: satisfaction_data
      ).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end

    it "calculates result correctly" do
      data = Glare::UxMetrics::Satisfaction::Parser.new(
        choices: satisfaction_data
      )
      
      # Calculate expected result based on implementation
      expected_result = satisfaction_data[:very_satisfied] + satisfaction_data[:somewhat_satisfied]
      
      expect(data.result).to be_within(0.001).of(expected_result)
    end

    it "assigns 'High' label for result > 0.8" do
      high_score_data = {
        very_dissatisfied: 0.05,
        somewhat_dissatisfied: 0.05,
        neutral: 0.05,
        somewhat_satisfied: 0.35,
        very_satisfied: 0.5
      }
      
      data = Glare::UxMetrics::Satisfaction::Parser.new(
        choices: high_score_data
      ).parse
      
      expect(data.threshold).to eq("positive")
      expect(data.label).to eq("High")
    end

    it "assigns 'Avg' label for result > 0.6 and <= 0.8" do
      medium_score_data = {
        very_dissatisfied: 0.1,
        somewhat_dissatisfied: 0.1,
        neutral: 0.1,
        somewhat_satisfied: 0.3,
        very_satisfied: 0.4
      }
      
      data = Glare::UxMetrics::Satisfaction::Parser.new(
        choices: medium_score_data
      ).parse
      
      expect(data.threshold).to eq("neutral")
      expect(data.label).to eq("Avg")
    end

    it "assigns 'Low' label for result <= 0.6" do
      low_score_data = {
        very_dissatisfied: 0.2,
        somewhat_dissatisfied: 0.2,
        neutral: 0.2,
        somewhat_satisfied: 0.2,
        very_satisfied: 0.2
      }
      
      data = Glare::UxMetrics::Satisfaction::Parser.new(
        choices: low_score_data
      ).parse
      
      expect(data.threshold).to eq("negative")
      expect(data.label).to eq("Low")
    end
  end

  describe Glare::UxMetrics::Comprehension do
    let(:comprehension_data) do
      {
        did_not_understand: 0.1,
        understood_a_little: 0.1,
        understood_most_of_it: 0.4,
        understood_very_well: 0.4
      }
    end

    it "validates valid comprehension data" do
      data = Glare::UxMetrics::Comprehension::Parser.new(
        choices: comprehension_data
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid comprehension data" do
      data = Glare::UxMetrics::Comprehension::Parser.new(choices: { helpful: 1 })
      expect(data.valid?).to eq(false)
    end

    it "invalidates when missing required keys" do
      incomplete_data = {
        did_not_understand: 0.1,
        understood_a_little: 0.1,
        understood_most_of_it: 0.4
        # missing understood_very_well
      }
      data = Glare::UxMetrics::Comprehension::Parser.new(choices: incomplete_data)
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Comprehension::Parser.new(
        choices: comprehension_data
      ).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end

    it "calculates result correctly" do
      data = Glare::UxMetrics::Comprehension::Parser.new(
        choices: comprehension_data
      )
      
      # Calculate expected result based on implementation
      positive_impressions = comprehension_data[:understood_very_well] + 
                             comprehension_data[:understood_most_of_it]
      negative_impressions = comprehension_data[:did_not_understand] + 
                             comprehension_data[:understood_a_little]
      
      expected_result = positive_impressions - negative_impressions
      
      expect(data.result).to be_within(0.001).of(expected_result)
    end

    it "assigns 'High' label for result > 0.7" do
      high_score_data = {
        did_not_understand: 0.05,
        understood_a_little: 0.05,
        understood_most_of_it: 0.4,
        understood_very_well: 0.5
      }
      
      data = Glare::UxMetrics::Comprehension::Parser.new(
        choices: high_score_data
      ).parse
      
      expect(data.threshold).to eq("positive")
      expect(data.label).to eq("High")
    end

    it "assigns 'Average' label for result > 0.4 and <= 0.7" do
      medium_score_data = {
        did_not_understand: 0.1,
        understood_a_little: 0.1,
        understood_most_of_it: 0.3,
        understood_very_well: 0.5
      }
      
      data = Glare::UxMetrics::Comprehension::Parser.new(
        choices: medium_score_data
      ).parse
      
      expect(data.threshold).to eq("neutral")
      expect(data.label).to eq("Average")
    end

    it "assigns 'Low' label for result <= 0.4" do
      low_score_data = {
        did_not_understand: 0.3,
        understood_a_little: 0.3,
        understood_most_of_it: 0.2,
        understood_very_well: 0.2
      }
      
      data = Glare::UxMetrics::Comprehension::Parser.new(
        choices: low_score_data
      ).parse
      
      expect(data.threshold).to eq("negative")
      expect(data.label).to eq("Low")
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

  describe Glare::UxMetrics::Reaction do
    let(:reaction_data) do
      {
        very_satisfied: 0.1,
        somewhat_satisfied: 0.1,
        neutral: 0.1,
        somewhat_dissatisfied: 0.1,
        very_dissatisfied: 0.1,
      }
    end

    it "validates valid reaction data" do
      data = Glare::UxMetrics::Reaction::Parser.new(
        choices: reaction_data,
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid reaction data" do
      data = Glare::UxMetrics::Reaction::Parser.new(choices: { ha: "bla" })
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Reaction::Parser.new(
        choices: reaction_data,
      ).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end
  end

  describe Glare::UxMetrics::Usefulness do
    let(:usefulness_data) do
      [{
        strongly_agree: 0.1,
        agree: 0.1,
        neutral: 0.1,
        disagree: 0.1,
        strongly_disagree: 0.1,
      }]
    end

    it "validates valid usefulness data" do
      data = Glare::UxMetrics::Usefulness::Parser.new(
        questions: usefulness_data
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid usefulness data" do
      data = Glare::UxMetrics::Usefulness::Parser.new(questions: [{ ha: "bla" }])
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Usefulness::Parser.new(
        questions: usefulness_data
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

    it "invalidates if no market recognition answers are selected" do
      data = Glare::UxMetrics::BrandScore::Parser.new(
        nps_question: brand_score_data[0],
        market_recognition_question: [
          { selected: false, percent: 0.1 },
          { selected: false, percent: 0.1 },
          { selected: false, percent: 0.1 },
          { selected: false, percent: 0.1 },
        ],
        npa_question: brand_score_data[2],
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
      }
    end

    it "validates valid completion data" do
      data = Glare::UxMetrics::Completion::Parser.new(
        direct_success: completion_data[:direct_success],
        indirect_success: completion_data[:indirect_success],
      )
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid completion data" do
      data = Glare::UxMetrics::Completion::Parser.new(direct_success: "yooo", indirect_success: "yooo")
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Completion::Parser.new(
        direct_success: completion_data[:direct_success],
        indirect_success: completion_data[:indirect_success],
      ).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end
  end

  describe Glare::UxMetrics::Engagement do
    let(:data) do
      {
        primary_clicks_count: 6,
        secondary_clicks_count: 2,
        tertiary_clicks_count: 2,
        total_clicks_count: 12
      }
    end

    it "validates valid engagement data" do
      parser = Glare::UxMetrics::Engagement::Parser.new(
        primary_clicks_count: data[:primary_clicks_count],
        secondary_clicks_count: data[:secondary_clicks_count],
        tertiary_clicks_count: data[:tertiary_clicks_count],
        total_clicks_count: data[:total_clicks_count]
      )
      expect(parser.valid?).to eq(true)
    end

    it "invalidates invalid engagement data" do
      parser = Glare::UxMetrics::Engagement::Parser.new(
        primary_clicks_count: "not a number",
        secondary_clicks_count: 2,
        tertiary_clicks_count: 2,
        total_clicks_count: 12
      )
      expect(parser.valid?).to eq(false)
    end

    it "returns valid data" do
      parser = Glare::UxMetrics::Engagement::Parser.new(
        primary_clicks_count: data[:primary_clicks_count],
        secondary_clicks_count: data[:secondary_clicks_count],
        tertiary_clicks_count: data[:tertiary_clicks_count],
        total_clicks_count: data[:total_clicks_count]
      ).parse
      expect(parser.result.is_a?(Float) && parser.label.is_a?(String) && parser.threshold.is_a?(String)).to eq(true)
    end

    it "calculates score correctly" do
      parser = Glare::UxMetrics::Engagement::Parser.new(
        primary_clicks_count: data[:primary_clicks_count],
        secondary_clicks_count: data[:secondary_clicks_count],
        tertiary_clicks_count: data[:tertiary_clicks_count],
        total_clicks_count: data[:total_clicks_count]
      )
      
      # Calculate expected score
      primary_score = (data[:primary_clicks_count] / data[:total_clicks_count].to_f) * Glare::UxMetrics::Engagement::Parser::PRIMARY_WEIGHT
      secondary_score = (data[:secondary_clicks_count] / data[:total_clicks_count].to_f) * Glare::UxMetrics::Engagement::Parser::SECONDARY_WEIGHT
      tertiary_score = (data[:tertiary_clicks_count] / data[:total_clicks_count].to_f) * Glare::UxMetrics::Engagement::Parser::TERTIARY_WEIGHT
      expected_score = primary_score + secondary_score + tertiary_score

      expect(parser.parse.result).to be_within(0.001).of(expected_score)
    end

    it "assigns 'High' label for score > 0.7" do
      high_score_data = {
        primary_clicks_count: 8,
        secondary_clicks_count: 2,
        tertiary_clicks_count: 0,
        total_clicks_count: 10
      }
      parser = Glare::UxMetrics::Engagement::Parser.new(
        primary_clicks_count: high_score_data[:primary_clicks_count],
        secondary_clicks_count: high_score_data[:secondary_clicks_count],
        tertiary_clicks_count: high_score_data[:tertiary_clicks_count],
        total_clicks_count: high_score_data[:total_clicks_count]
      ).parse
      expect(parser.label).to eq("High")
      expect(parser.threshold).to eq("positive")
    end

    it "assigns 'Avg' label for score >= 0.5 and <= 0.7" do
      avg_score_data = {
        primary_clicks_count: 5,
        secondary_clicks_count: 2,
        tertiary_clicks_count: 0,
        total_clicks_count: 10
      }
      parser = Glare::UxMetrics::Engagement::Parser.new(
        primary_clicks_count: avg_score_data[:primary_clicks_count],
        secondary_clicks_count: avg_score_data[:secondary_clicks_count],
        tertiary_clicks_count: avg_score_data[:tertiary_clicks_count],
        total_clicks_count: avg_score_data[:total_clicks_count]
      ).parse
      expect(parser.label).to eq("Avg")
      expect(parser.threshold).to eq("neutral")
    end

    it "assigns 'Low' label for score < 0.5" do
      low_score_data = {
        primary_clicks_count: 2,
        secondary_clicks_count: 1,
        tertiary_clicks_count: 1,
        total_clicks_count: 10
      }
      parser = Glare::UxMetrics::Engagement::Parser.new(
        primary_clicks_count: low_score_data[:primary_clicks_count],
        secondary_clicks_count: low_score_data[:secondary_clicks_count],
        tertiary_clicks_count: low_score_data[:tertiary_clicks_count],
        total_clicks_count: low_score_data[:total_clicks_count]
      ).parse
      expect(parser.label).to eq("Low")
      expect(parser.threshold).to eq("negative")
    end
  end

  describe Glare::UxMetrics::Usability do
    let(:usability_data) do
      [
        {
          average_primary_percentage: 0.4,
          average_secondary_percentage: 0.2,
          average_tertiary_percentage: 0.0
        },
        {
          average_primary_percentage: 0.3,
          average_secondary_percentage: 0.3,
          average_tertiary_percentage: 0.1
        }
      ]
    end

    it "validates valid usability data" do
      parser = Glare::UxMetrics::Usability::Parser.new(questions: usability_data)
      expect(parser.valid?).to eq(true)
    end

    it "invalidates empty questions array" do
      parser = Glare::UxMetrics::Usability::Parser.new(questions: [])
      expect(parser.valid?).to eq(false)
    end

    it "invalidates non-array questions" do
      parser = Glare::UxMetrics::Usability::Parser.new(questions: "not an array")
      expect(parser.valid?).to eq(false)
    end

    it "invalidates questions with missing required keys" do
      invalid_data = [
        {
          average_primary_percentage: 0.4,
          average_secondary_percentage: 0.2
          # missing average_tertiary_percentage
        }
      ]
      parser = Glare::UxMetrics::Usability::Parser.new(questions: invalid_data)
      expect(parser.valid?).to eq(false)
    end

    it "returns valid data" do
      parser = Glare::UxMetrics::Usability::Parser.new(questions: usability_data).parse
      expect(parser.result.is_a?(Float) && parser.label.is_a?(String) && parser.threshold.is_a?(String)).to eq(true)
    end

    it "assigns 'Good' label for score >= 0.8" do
      high_score_data = [
        {
          average_primary_percentage: 0.9,
          average_secondary_percentage: 0.8,
          average_tertiary_percentage: 0.7
        }
      ]
      parser = Glare::UxMetrics::Usability::Parser.new(questions: high_score_data).parse
      expect(parser.label).to eq("Good")
      expect(parser.threshold).to eq("positive")
    end

    it "assigns 'Avg' label for score >= 0.6 and < 0.8" do
      medium_score_data = [
        {
          average_primary_percentage: 0.7,
          average_secondary_percentage: 0.6,
          average_tertiary_percentage: 0.5
        }
      ]
      parser = Glare::UxMetrics::Usability::Parser.new(questions: medium_score_data).parse
      expect(parser.label).to eq("Avg")
      expect(parser.threshold).to eq("neutral")
    end

    it "assigns 'Low' label for score < 0.6" do
      low_score_data = [
        {
          average_primary_percentage: 0.4,
          average_secondary_percentage: 0.3,
          average_tertiary_percentage: 0.2
        }
      ]
      parser = Glare::UxMetrics::Usability::Parser.new(questions: low_score_data).parse
      expect(parser.label).to eq("Low")
      expect(parser.threshold).to eq("negative")
    end

    it "calculates score correctly" do
      parser = Glare::UxMetrics::Usability::Parser.new(questions: usability_data)
      
      # Calculate expected score
      expected_score = (
        (0.4 + 0.3) / 2 + # average primary
        (0.2 + 0.3) / 2 + # average secondary
        (0.0 + 0.1) / 2   # average tertiary
      ) / 3

      expect(parser.parse.result).to be_within(0.001).of(expected_score)
    end
  end

  describe Glare::UxMetrics::Success do
    let(:success_data) do
      [
        {
          average_primary_percentage: 0.4,
          average_secondary_percentage: 0.2,
          average_tertiary_percentage: 0.0
        },
        {
          average_primary_percentage: 0.3,
          average_secondary_percentage: 0.3,
          average_tertiary_percentage: 0.1
        }
      ]
    end

    it "validates valid success data" do
      parser = Glare::UxMetrics::Success::Parser.new(questions: success_data)
      expect(parser.valid?).to eq(true)
    end

    it "invalidates empty questions array" do
      parser = Glare::UxMetrics::Success::Parser.new(questions: [])
      expect(parser.valid?).to eq(false)
    end

    it "invalidates non-array questions" do
      parser = Glare::UxMetrics::Success::Parser.new(questions: "not an array")
      expect(parser.valid?).to eq(false)
    end

    it "invalidates questions with missing required keys" do
      invalid_data = [
        {
          average_primary_percentage: 0.4,
          average_secondary_percentage: 0.2
          # missing average_tertiary_percentage
        }
      ]
      parser = Glare::UxMetrics::Success::Parser.new(questions: invalid_data)
      expect(parser.valid?).to eq(false)
    end

    it "returns valid data" do
      parser = Glare::UxMetrics::Success::Parser.new(questions: success_data).parse
      expect(parser.result.is_a?(Float) && parser.label.is_a?(String) && parser.threshold.is_a?(String)).to eq(true)
    end

    it "assigns 'High' label for high scores" do
      high_score_data = [
        {
          average_primary_percentage: 0.95, # >= 90
          average_secondary_percentage: 0.85, # >= 80
          average_tertiary_percentage: 0.70 # >= 65
        }
      ]
      parser = Glare::UxMetrics::Success::Parser.new(questions: high_score_data).parse
      expect(parser.label).to eq("High")
      expect(parser.threshold).to eq("positive")
    end

    it "assigns 'Avg' label for average scores" do
      avg_score_data = [
        {
          average_primary_percentage: 0.85, # >= 80 and < 90
          average_secondary_percentage: 0.75, # >= 70 and < 80
          average_tertiary_percentage: 0.60 # >= 55 and < 65
        }
      ]
      parser = Glare::UxMetrics::Success::Parser.new(questions: avg_score_data).parse
      expect(parser.label).to eq("Avg")
      expect(parser.threshold).to eq("neutral")
    end

    it "assigns 'Low' label for low scores" do
      low_score_data = [
        {
          average_primary_percentage: 0.75, # < 80
          average_secondary_percentage: 0.65, # < 70
          average_tertiary_percentage: 0.50 # < 55
        }
      ]
      parser = Glare::UxMetrics::Success::Parser.new(questions: low_score_data).parse
      expect(parser.label).to eq("Low")
      expect(parser.threshold).to eq("negative")
    end

    it "calculates score correctly" do
      parser = Glare::UxMetrics::Success::Parser.new(questions: success_data)
      
      # Calculate expected score
      expected_score = (
        (0.4 + 0.3) / 2 + # average primary
        (0.2 + 0.3) / 2 + # average secondary
        (0.0 + 0.1) / 2   # average tertiary
      ) / 3

      expect(parser.parse.result).to be_within(0.001).of(expected_score)
    end

    it "identifies high scorer based on primary score" do
      data = [
        {
          average_primary_percentage: 0.95, # >= 90
          average_secondary_percentage: 0.70, # < 80
          average_tertiary_percentage: 0.60 # < 65
        }
      ]
      parser = Glare::UxMetrics::Success::Parser.new(questions: data).parse
      expect(parser.label).to eq("High")
    end

    it "identifies high scorer based on secondary score" do
      data = [
        {
          average_primary_percentage: 0.85, # < 90
          average_secondary_percentage: 0.85, # >= 80
          average_tertiary_percentage: 0.60 # < 65
        }
      ]
      parser = Glare::UxMetrics::Success::Parser.new(questions: data).parse
      expect(parser.label).to eq("High")
    end

    it "identifies high scorer based on tertiary score" do
      data = [
        {
          average_primary_percentage: 0.85, # < 90
          average_secondary_percentage: 0.75, # < 80
          average_tertiary_percentage: 0.70 # >= 65
        }
      ]
      parser = Glare::UxMetrics::Success::Parser.new(questions: data).parse
      expect(parser.label).to eq("High")
    end

    it "identifies avg scorer based on primary score" do
      data = [
        {
          average_primary_percentage: 0.85, # >= 80 and < 90
          average_secondary_percentage: 0.65, # < 70
          average_tertiary_percentage: 0.50 # < 55
        }
      ]
      parser = Glare::UxMetrics::Success::Parser.new(questions: data).parse
      expect(parser.label).to eq("Avg")
    end

    it "identifies avg scorer based on secondary score" do
      data = [
        {
          average_primary_percentage: 0.75, # < 80
          average_secondary_percentage: 0.75, # >= 70 and < 80
          average_tertiary_percentage: 0.50 # < 55
        }
      ]
      parser = Glare::UxMetrics::Success::Parser.new(questions: data).parse
      expect(parser.label).to eq("Avg")
    end

    it "identifies avg scorer based on tertiary score" do
      data = [
        {
          average_primary_percentage: 0.75, # < 80
          average_secondary_percentage: 0.65, # < 70
          average_tertiary_percentage: 0.60 # >= 55 and < 65
        }
      ]
      parser = Glare::UxMetrics::Success::Parser.new(questions: data).parse
      expect(parser.label).to eq("Avg")
    end
  end

  describe Glare::UxMetrics::Intent do
    let(:intent_data) do
      {
        primary: 0.3,
        secondary: 0.2,
        tertiary: 0.1
      }
    end

    it "validates valid intent data" do
      data = Glare::UxMetrics::Intent::Parser.new(choices: intent_data)
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid intent data" do
      data = Glare::UxMetrics::Intent::Parser.new(choices: { primary: "not a number" })
      expect(data.valid?).to eq(false)
    end

    it "invalidates when missing required keys" do
      data = Glare::UxMetrics::Intent::Parser.new(choices: { primary: 0.3, secondary: 0.2 })
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Intent::Parser.new(choices: intent_data).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end

    it "calculates score correctly" do
      parser = Glare::UxMetrics::Intent::Parser.new(choices: intent_data)
      # Expected score = (primary * 3 + secondary * 2 + tertiary) / 3
      expected_score = (0.3 * 3 + 0.2 * 2 + 0.1) / 3
      expect(parser.result).to be_within(0.001).of(expected_score)
    end

    it "assigns 'High Intent' label for score > 0.6" do
      high_score_data = {
        primary: 0.9,
        secondary: 0.8,
        tertiary: 0.7
      }
      data = Glare::UxMetrics::Intent::Parser.new(choices: high_score_data).parse
      expect(data.label).to eq("High Intent")
      expect(data.threshold).to eq("positive")
    end

    it "assigns 'Avg Intent' label for score >= 0.4 and <= 0.6" do
      avg_score_data = {
        primary: 0.4,
        secondary: 0.1,
        tertiary: 0.1
      }
      data = Glare::UxMetrics::Intent::Parser.new(choices: avg_score_data).parse
      expect(data.label).to eq("Avg Intent")
      expect(data.threshold).to eq("neutral")
    end

    it "assigns 'Low Intent' label for score < 0.4" do
      low_score_data = {
        primary: 0.2,
        secondary: 0.1,
        tertiary: 0.0
      }
      data = Glare::UxMetrics::Intent::Parser.new(choices: low_score_data).parse
      expect(data.label).to eq("Low Intent")
      expect(data.threshold).to eq("negative")
    end

    it "handles string number inputs" do
      string_data = {
        primary: "3",
        secondary: "2",
        tertiary: "1"
      }
      data = Glare::UxMetrics::Intent::Parser.new(choices: string_data)
      expect(data.valid?).to eq(true)
      expect(data.result).to be_within(0.001).of((3.0 * 3 + 2.0 * 2 + 1.0) / 3)
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

  describe Glare::UxMetrics::Effort do
    let(:effort_data) do
      {
        choices: [5, 4, 3, 5, 4, 3, 2, 1]
      }
    end

    it "validates valid effort data" do
      data = Glare::UxMetrics::Effort::Parser.new(nps_question: effort_data)
      expect(data.valid?).to eq(true)
    end

    it "invalidates when not a hash" do
      data = Glare::UxMetrics::Effort::Parser.new(nps_question: "not a hash")
      expect(data.valid?).to eq(false)
    end

    it "invalidates when missing choices key" do
      data = Glare::UxMetrics::Effort::Parser.new(nps_question: { wrong_key: [1, 2, 3] })
      expect(data.valid?).to eq(false)
    end

    it "invalidates when choices is not an array" do
      data = Glare::UxMetrics::Effort::Parser.new(nps_question: { choices: "not an array" })
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Effort::Parser.new(nps_question: effort_data).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end

    it "calculates score correctly" do
      parser = Glare::UxMetrics::Effort::Parser.new(nps_question: effort_data)
      # Expected score = sum of choices / count of choices / 5
      expected_score = effort_data[:choices].sum / effort_data[:choices].count.to_f / 5
      expect(parser.parse.result).to be_within(0.001).of(expected_score)
    end

    it "assigns 'Excellent' label for score >= 0.8571" do
      high_score_data = {
        choices: [5, 5, 5, 5, 5, 4, 4, 4]
      }
      data = Glare::UxMetrics::Effort::Parser.new(nps_question: high_score_data).parse
      expect(data.label).to eq("Excellent")
      expect(data.threshold).to eq("positive")
    end

    it "assigns 'Average' label for score >= 0.5714 and < 0.8571" do
      medium_score_data = {
        choices: [4, 3, 3, 3, 3, 3, 2, 3]
      }
      data = Glare::UxMetrics::Effort::Parser.new(nps_question: medium_score_data).parse
      expect(data.label).to eq("Average")
      expect(data.threshold).to eq("neutral")
    end

    it "assigns 'Low' label for score < 0.5714" do
      low_score_data = {
        choices: [3, 2, 2, 2, 2, 1, 1, 1]
      }
      data = Glare::UxMetrics::Effort::Parser.new(nps_question: low_score_data).parse
      expect(data.label).to eq("Low")
      expect(data.threshold).to eq("negative")
    end
  end

  describe Glare::UxMetrics::Loyalty do
    let(:loyalty_data) do
      [
        0.1, # highest (promoters)
        0.2,
        0.1, # passives
        0.05,
        0.09, # detractors
        0.05,
        0.1,
        0.01,
        0.02,
        0.02 # lowest
      ]
    end

    it "validates valid loyalty data" do
      data = Glare::UxMetrics::Loyalty::Parser.new(choices: loyalty_data)
      expect(data.valid?).to eq(true)
    end

    it "invalidates invalid loyalty data" do
      data = Glare::UxMetrics::Loyalty::Parser.new(choices: [0.1, 0.2]) # Not enough choices
      expect(data.valid?).to eq(false)
    end

    it "returns valid data" do
      data = Glare::UxMetrics::Loyalty::Parser.new(choices: loyalty_data).parse
      expect(data.result.is_a?(Float) && data.label.is_a?(String) && data.threshold.is_a?(String)).to eq(true)
    end

    it "calculates NPS score correctly" do
      parser = Glare::UxMetrics::Loyalty::Parser.new(choices: loyalty_data)
      # Expected NPS = Promoters (0.1 + 0.2) - Detractors (0.09 + 0.05 + 0.1 + 0.01 + 0.02 + 0.02)
      expected_score = (0.1 + 0.2) - (0.09 + 0.05 + 0.1 + 0.01 + 0.02 + 0.02)
      expect(parser.nps_score).to be_within(0.001).of(expected_score)
    end

    it "assigns 'High' label for NPS >= 0.3" do
      high_nps_data = [
        0.4, # promoters
        0.4,
        0.1, # passives
        0.05,
        0.01, # detractors
        0.01,
        0.01,
        0.01,
        0.005,
        0.005
      ]
      data = Glare::UxMetrics::Loyalty::Parser.new(choices: high_nps_data).parse
      expect(data.label).to eq("High")
      expect(data.threshold).to eq("positive")
    end

    it "assigns 'Average' label for NPS >= 0.0 and < 0.3" do
      avg_nps_data = [
        0.2, # promoters
        0.2,
        0.2, # passives
        0.2,
        0.1, # detractors
        0.05,
        0.02,
        0.02,
        0.01,
        0.01
      ]
      data = Glare::UxMetrics::Loyalty::Parser.new(choices: avg_nps_data).parse
      expect(data.label).to eq("Average")
      expect(data.threshold).to eq("neutral")
    end

    it "assigns 'Low' label for NPS < 0.0" do
      low_nps_data = [
        0.1, # promoters
        0.1,
        0.1, # passives
        0.1,
        0.2, # detractors
        0.2,
        0.1,
        0.05,
        0.03,
        0.02
      ]
      data = Glare::UxMetrics::Loyalty::Parser.new(choices: low_nps_data).parse
      expect(data.label).to eq("Low")
      expect(data.threshold).to eq("negative")
    end

    it "provides correct breakdown of promoters, passives, and detractors" do
      parser = Glare::UxMetrics::Loyalty::Parser.new(choices: loyalty_data)
      breakdown = parser.breakdown
      
      expect(breakdown[:promoters]).to be_within(0.001).of(0.1 + 0.2)
      expect(breakdown[:passives]).to be_within(0.001).of(0.1 + 0.05)
      expect(breakdown[:detractors]).to be_within(0.001).of(0.09 + 0.05 + 0.1 + 0.01 + 0.02 + 0.02)
    end
  end
end
