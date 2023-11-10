class Foo
  def initialize(repository_path:, score_weights: {})
    @repo_path = repository_path
    @score_weights = score_weights
  end

  def structural_similarity_score_per_file(folders)
    score_line = `flay #{folders}/* | head -n 1`
    score_number = Float(score_line.split(" ").last)
    weighted_score = score_number * @score_weights[:similarity]
    weighted_score.round(2)
  end

  def abc_method_average_score(folders)
    score_line = `flog #{folders}/* | head -n 2 | tail -1`
    score = Float(score_line.split(":").first)
    weighted_score = score * @score_weights[:abc_method]
    weighted_score.round(2)
  end

  def code_smells_per_file(folders, file_count)
    score_line = `reek #{folders}/* | tail -1`
    score_number = Float(score_line.split(" ").first)
    score_per_file = score_number / file_count
    weighted_score = score_per_file * @score_weights[:code_smells]
    weighted_score.round(2)
  end
end