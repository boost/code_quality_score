# frozen_string_literal: true

require_relative "./lib"

module CodeQualityScore
  class FormatComparison
    def self.format_as_markdown(base_result, pr_result)
      difference_result = base_result.map do |key, value|
        difference_value = pr_result[key] - value
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
        ## Code quality audit
        The code quality has #{intro_summary} for this PR.

        |         | Similarity score | ABC complexity | Code smells | TOTALS |
        |---------|------------------|----------------|-------------|--------|
        #{format_row("base", base_result)}
        #{format_row("this branch", pr_result)}
        #{format_row("difference", difference_result)}

      HEREDOC

      puts result
    end

    def self.format_row(name, hash)
      sim_score = hash[:similarity_score_per_file]
      abc_score = hash[:abc_method_average]
      smells_score = hash[:code_smells_per_file]
      total = hash[:total_score]

      "| #{name} | #{sim_score} | #{abc_score} | #{smells_score} | #{total} |"
    end
  end
end
