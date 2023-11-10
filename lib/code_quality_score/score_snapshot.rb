# frozen_string_literal: true
require 'pry-byebug'

module CodeQualityScore
  class ScoreSnapshot
    def initialize(repository_path:, similarity_score_leveler: 1000)
      @repo_path = repository_path
      @similarity_score_leveler = similarity_score_leveler
    end

    def calculate_score
      folders = find_folders.join(' ')
      file_count = count_files(folders)

      result = {
        similarity_score: structural_similarity_score_per_file(folders),
        abc_method_average: abc_method_average_score(folders),
        code_smells_per_file: code_smells_per_file(folders, file_count),
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

    def structural_similarity_score_per_file(folders)
      score_line = `flay #{folders}/* | head -n 1`
      score_number = Float(score_line.split(" ").last)
      (score_number / @similarity_score_leveler).round(2)
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
