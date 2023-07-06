# frozen_string_literal: true

def folder(solution)
  solution[:folder] || "app"
end

def app_folder_file_count(solution)
  Integer(`find #{solution[:relative_path]}#{solution[:name]}/#{folder(solution)} -type f | wc -l`)
end

def structural_similarity_score_per_file(solution)
  score_line = `flay #{solution[:relative_path]}#{folder(solution)}/* | head -n 1`
  score_number = Float(score_line.split(" ").last)
  (score_number / app_folder_file_count(solution)).round(2)
end

def abc_method_average_score(solution)
  score_line = `flog #{solution[:relative_path]}#{folder(solution)}/* | head -n 2 | tail -1`
  Float(score_line.split(":").first).round(2)
end

def code_smells_per_file(solution)
  score_line = `reek #{solution[:relative_path]}#{folder(solution)}/* | tail -1`
  score_number = Float(score_line.split(" ").first)
  (score_number / app_folder_file_count(solution)).round(2)
end
