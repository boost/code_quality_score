# frozen_string_literal: true

module CodeQualityScore
  class ScoreSnapshot
    def initialize(repository_path:)
      @repo_path = repository_path
    end

    def calculate_score
      folders = find_folders.join(' ')
      file_count = count_files(folders)

      result = {
        similarity_score_per_file: structural_similarity_score_per_file(folders, file_count),
        abc_method_average: abc_method_average_score(folders),
        code_smells_per_file: code_smells_per_file(folders, file_count)
      }

      result[:total_score] = result.values.sum.round(2)

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

    def structural_similarity_score_per_file(folders, file_count)
      score_line = `flay #{folders}/* | head -n 1`
      score_number = Float(score_line.split(" ").last)
      (score_number / file_count).round(2)
    end

    def abc_method_average_score(folders)
      score_line = `flog #{folders}/* | head -n 2 | tail -1`
      Float(score_line.split(":").first)
    end

    def code_smells_per_file(folders, file_count)
      score_line = `reek #{folders}/* | tail -1`
      score_number = Float(score_line.split(" ").first)
      (score_number / file_count).round(2)
    end
  end
end
