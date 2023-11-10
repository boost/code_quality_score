# frozen_string_literal: true

require "code_quality_score/score_snapshot"

RSpec.describe CodeQualityScore::ScoreSnapshot do
  subject(:score_snapshot) { CodeQualityScore::ScoreSnapshot.new(repository_path: "./spec/test_project") }
  let(:expected_scores) do
    {
      abc_method_average: 8.5,
      code_smells_per_file: 0.5,
      similarity_score: 44.0,
      total_file_count: 2,
      total_score: 53.0
    }
  end

  it "has a version number" do
    expect(CodeQualityScore::VERSION).not_to be nil
  end

  it "calculates scores for a repository as expected" do
    expect(score_snapshot.calculate_score).to eq(expected_scores)
  end

  context "when custom score weights are passed" do
    subject(:score_snapshot) { CodeQualityScore::ScoreSnapshot.new(repository_path: "./spec/test_project", score_weights: score_weights) }
    let(:score_weights) do
      {
        similarity_score: 0.001,
        abc_method_average: 3,
        code_smells_per_file: 10
      }
    end

    it "multiplies the scores by the new weights" do
      result = score_snapshot.calculate_score

      [:similarity_score, :abc_method_average, :code_smells_per_file].each do |score_type|
        actual = result[score_type]
        expected = (expected_scores[score_type] * score_weights[score_type]).round(2)
        expect(actual).to eq(expected)
      end
    end
  end
end
