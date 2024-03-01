# frozen_string_literal: true

module CodeQualityScore
  class FormatComparison
    def self.format_as_markdown(base_result, pr_result)
      difference_result = base_result.map do |key, value|
        difference_value = (pr_result[key] - value).round(2)
        [key, difference_value]
      end.to_h

      total_score_difference = difference_result[:total_score]

      intro_text = if total_score_difference.negative?
                     "Nice work!! The code quality has improved for this PR!"
                   elsif total_score_difference.zero?
                     "Lovely, the code quality is unchanged for this PR"
                   else
                     "Uh oh! The code quality got worse for this PR! Better take a look!!"
                   end

      summary_emoji = if total_score_difference.negative?
                        ":sparkles: :rainbow: :tada: :star2:"
                      elsif total_score_difference.zero?
                        ":blush:"
                      else
                        ":rotating_light:"
                      end

      result = <<~HEREDOC
        ## Code quality score
        #{intro_text} #{summary_emoji}

        |         | Ruby file count | Similarity score (flay) | ABC complexity (flog) | Code smells (reek) | TOTALS |
        |---------|-----------------|------------------|----------------|-------------|--------|
        #{format_row("base", base_result, false)}
        #{format_row("this branch", pr_result, false)}
        #{format_row("difference", difference_result, true)}

      HEREDOC

      puts result
    end

    def self.format_row(name, hash, with_emoji)
      ruby_files = hash[:ruby_file_count]
      sim_score = format_value(hash[:similarity_score], with_emoji)
      abc_score = format_value(hash[:abc_method_average], with_emoji)
      smells_score = format_value(hash[:code_smells_per_file], with_emoji)
      total = hash[:total_score]

      "| #{name} | #{ruby_files} | #{sim_score} | #{abc_score} | #{smells_score} | #{total} |"
    end

    def self.format_value(number, with_emoji)
      return ":warning: #{number}" if with_emoji && number.positive?

      number.to_s
    end
  end
end
