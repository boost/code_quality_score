# frozen_string_literal: true

module CodeQualityScore
  class FormatComparison
    def self.format_as_markdown(base_result, pr_result)
      difference_result = base_result.map do |key, value|
        difference_value = (pr_result[key] - value).round(2)
        [key, difference_value]
      end.to_h

      total_score_difference = difference_result[:total_score]

      intro_summary = if total_score_difference.negative?
                        "improved"
                      elsif total_score_difference.zero?
                        "not changed"
                      else
                        "got worse"
                      end

      result = <<~HEREDOC
        ## Code quality score
        The code quality has #{intro_summary} for this PR.

        |         | Ruby file count | Similarity score | ABC complexity | Code smells | TOTALS |
        |---------|-----------------|------------------|----------------|-------------|--------|
        #{format_row("base", base_result)}
        #{format_row("this branch", pr_result)}
        #{format_row("difference", difference_result)}

      HEREDOC

      puts result
    end

    def self.format_row(name, hash)
      ruby_files = hash[:ruby_file_count]
      sim_score = hash[:similarity_score]
      abc_score = hash[:abc_method_average]
      smells_score = hash[:code_smells_per_file]
      total = hash[:total_score]

      "| #{name} | #{ruby_files} | #{sim_score} | #{abc_score} | #{smells_score} | #{total} |"
    end
  end
end
