def folder(solution)
  solution[:folder] ? solution[:folder] : 'app'
end

def app_folder_file_count(solution)
  count = Integer(`find #{solution[:relative_path]}#{solution[:name]}/#{folder(solution)} -type f | wc -l`)
end

def structural_similarity_score_per_file(solution)
  puts "calculating flay score for #{solution[:name]}"
  score_line = `flay #{solution[:relative_path]}#{solution[:name]}/#{folder(solution)}/* | head -n 1`
  score_number = Float(score_line.split(" ").last)
  average_per_file = (score_number / app_folder_file_count(solution)).round(2)

  average_per_file
end

def abc_method_average_score(solution)
  puts "calculating flog score for #{solution[:name]}"
  score_line = `flog #{solution[:relative_path]}#{solution[:name]}/#{folder(solution)}/* | head -n 2 | tail -1`
  score_number = Float(score_line.split(":").first)

  score_number
end

def code_smells_per_file(solution)
  puts "calculating reek score for #{solution[:name]}"
  score_line = `reek #{solution[:relative_path]}#{solution[:name]}/#{folder(solution)}/* | tail -1`
  score_number = Float(score_line.split(" ").first)
  average_per_file = (score_number / app_folder_file_count(solution)).round(2)

  average_per_file
end