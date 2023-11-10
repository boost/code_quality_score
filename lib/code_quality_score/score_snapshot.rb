# frozen_string_literal: true
require 'pry-byebug'

module CodeQualityScore
  class ScoreSnapshot
    DEFAULT_SCORE_WEIGHTS = { similarity_score: 1, abc_method_average: 1, code_smells_per_file: 1 }.freeze

    def initialize(repository_path:, score_weights: {})
      @repo_path = repository_path
      @score_weights = DEFAULT_SCORE_WEIGHTS.merge(score_weights)
    end

    def calculate_score
      folders = find_folders.join(' ')
      file_count = count_files(folders)

      result = {
        similarity_score: structural_similarity_score(folders),
        abc_method_average: abc_method_average_score(folders),
        code_smells_per_file: code_smells_per_file(folders, file_count)
      }

      result[:total_score] = result.values.sum.round(2)
      result[:total_file_count] = file_count

      result
    end

    private

    def find_folders
      ["app", "lib"]
        .map { |dir| File.join(@repo_path, dir) }
        .select { |path| File.exist?(path) }
    end

    def count_files(folders)
      Integer(`find #{folders} -type f | wc -l`)
    end

    def structural_similarity_score(folders)
      score_line = `flay #{folders}/* | head -n 1`
      score_number = Float(score_line.split(" ").last).round(2)
      weighted_score = score_number * @score_weights[:similarity_score]
      weighted_score.round(2)
    end

    def abc_method_average_score(folders)
      score_line = `flog #{folders}/* | head -n 2 | tail -1`
      score = Float(score_line.split(":").first).round(2)
      weighted_score = score * @score_weights[:abc_method_average]
      weighted_score.round(2)
    end

    def code_smells_per_file(folders, file_count)
      score_line = `reek #{folders}/* | tail -1`
      score_number = Float(score_line.split(" ").first)
      score_per_file = (score_number / file_count).round(2)
      weighted_score = score_per_file * @score_weights[:code_smells_per_file]
      weighted_score.round(2)
    end
  end
end
