# frozen_string_literal: true
require "code_quality_score/score_snapshotter"

RSpec.describe CodeQualityScore do
  it "has a version number" do
    expect(CodeQualityScore::VERSION).not_to be nil
  end

  it "calculates scores" do
    expect(CodeQualityScore::ScoreSnapshotter.calculate_score_snapshot(true)).to eq({
      :abc_method_average => 6.8,
      :code_smells_per_file => 0.5,
      :similarity_score_per_file => 14.5,
      :total_score => 21.8,
    })
  end
end
