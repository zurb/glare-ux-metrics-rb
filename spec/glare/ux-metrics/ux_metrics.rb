# frozen_string_literal: true

RSpec.describe Glare::UxMetrics do
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

  describe Glare::UxMetrics::Sentiment do
    data = Glare::UxMetrics::Sentiment::Data.new(choices: sentiment_data)
    expect(data.valid?).to eq(true)
  end
end
