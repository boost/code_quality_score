# frozen_string_literal: true

require "code_quality_score/score_snapshot"

RSpec.describe CodeQualityScore::ScoreSnapshot do
  subject(:score_snapshot) { CodeQualityScore::ScoreSnapshot.new(repository_path: "./", similarity_score_leveler: 1000) }

  it "has a version number" do
    expect(CodeQualityScore::VERSION).not_to be nil
  end

  it "calculates scores for it's own code without error" do
    expect(score_snapshot.calculate_score).to eq({
                                                   abc_method_average: 6.0,
                                                   code_smells_per_file: 0.5,
                                                   similarity_score: 0.0,
                                                   total_file_count: 4,
                                                   total_score: 6.5
                                                 })
  end
end
