# frozen_string_literal: true

require "code_quality_score/score_snapshot"

RSpec.describe CodeQualityScore::ScoreSnapshot do
  subject(:score_snapshot) { CodeQualityScore::ScoreSnapshot.new(repository_path: "./spec/test_project", score_weights: score_weights) }
  let(:score_weights) do
    {
      similarity_score: 1,
      abc_method_average: 1,
      code_smells_per_file: 1
    }
  end
  let(:expected_scores) do
    {
      abc_method_average: 8.5,
      code_smells_per_file: 0.5,
      similarity_score: 44.0,
      total_file_count: 2,
      ruby_file_count: 2,
      total_score: 53.0
    }
  end

  it "has a version number" do
    expect(CodeQualityScore::VERSION).not_to be nil
  end

  it "calculates scores for a repository as expected" do
    expect(score_snapshot.calculate_score).to include(expected_scores)
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

  describe "file breakdown keys" do
    subject(:result) { score_snapshot.calculate_score }

    it "returns reek_files as an array of hashes with file and smells keys" do
      expect(result[:reek_files]).to be_an(Array)
      result[:reek_files].each do |entry|
        expect(entry).to include(:file, :smells)
        expect(entry[:file]).to end_with('.rb')
        expect(entry[:smells]).to be_a(Integer)
      end
    end

    it "returns reek_files sorted by smells descending" do
      smells = result[:reek_files].map { |h| h[:smells] }
      expect(smells).to eq(smells.sort.reverse)
    end

    it "returns flog_files as an array of hashes with file and score keys" do
      expect(result[:flog_files]).to be_an(Array)
      result[:flog_files].each do |entry|
        expect(entry).to include(:file, :score)
        expect(entry[:file]).to end_with('.rb')
        expect(entry[:score]).to be_a(Float)
      end
    end

    it "returns flog_files sorted by score descending" do
      scores = result[:flog_files].map { |h| h[:score] }
      expect(scores).to eq(scores.sort.reverse)
    end

    it "returns flay_blocks as an array of hashes with mass and locations keys" do
      expect(result[:flay_blocks]).to be_an(Array)
      result[:flay_blocks].each do |block|
        expect(block).to include(:mass, :locations)
        expect(block[:mass]).to be_a(Integer)
        expect(block[:locations]).to be_an(Array)
        block[:locations].each do |loc|
          expect(loc).to include(:file, :line)
          expect(loc[:file]).to end_with('.rb')
          expect(loc[:line]).to be_a(Integer)
        end
      end
    end

    it "returns flay_blocks sorted by mass descending" do
      masses = result[:flay_blocks].map { |b| b[:mass] }
      expect(masses).to eq(masses.sort.reverse)
    end
  end
end
