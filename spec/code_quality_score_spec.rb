# frozen_string_literal: true

require "code_quality_score/score_snapshot"

RSpec.describe CodeQualityScore::ScoreSnapshot do
  subject(:score_snapshot) { CodeQualityScore::ScoreSnapshot.new(repository_path: "./") }

  it "has a version number" do
    expect(CodeQualityScore::VERSION).not_to be nil
  end

  it "calculates scores for it's own code without error" do
    expect(score_snapshot.calculate_score).to eq({
                                                   abc_method_average: 5.9,
                                                   code_smells_per_file: 0.25,
                                                   similarity_score_per_file: 0.0,
                                                   total_score: 6.15
                                                 })
  end
end
