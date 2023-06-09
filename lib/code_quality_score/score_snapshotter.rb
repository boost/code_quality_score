# frozen_string_literal: true

require_relative "./lib"

module CodeQualityScore
  class ScoreSnapshotter
    def self.calculate_score_snapshot(is_gem, relative_path_to_repository: "./")
      solution = {
        relative_path: relative_path_to_repository,
        folder: is_gem ? "lib" : "app"
      }

      result = {
        similarity_score_per_file: structural_similarity_score_per_file(solution),
        abc_method_average: abc_method_average_score(solution),
        code_smells_per_file: code_smells_per_file(solution)
      }

      result[:total_score] = result.values.sum.round(2)

      result
    end
  end
end
