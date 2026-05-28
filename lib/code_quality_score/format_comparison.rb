# frozen_string_literal: true

module CodeQualityScore
  class FormatComparison
    def self.format_as_markdown(base_result, pr_result)
      difference_result = base_result.map do |key, value|
        next [key, value] unless value.is_a?(Numeric)

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

      result += format_file_breakdown(base_result, pr_result)
      result
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

    def self.format_file_breakdown(base_result, pr_result)
      sections = []

      reek_worse = (pr_result[:code_smells_per_file] || 0) > (base_result[:code_smells_per_file] || 0)
      if reek_worse
        base_reek = (base_result[:reek_files] || []).each_with_object({}) { |h, m| m[h[:file]] = h[:smells] }
        worse_reek = (pr_result[:reek_files] || []).select { |h| h[:smells] > (base_reek[h[:file]] || 0) }
        unless worse_reek.empty?
          lines = worse_reek.map { |h| "- `#{h[:file]}` — #{h[:smells]} smells (+#{h[:smells] - (base_reek[h[:file]] || 0)})" }.join("\n")
          sections << <<~MD
            <details>
            <summary>Files with more code smells than base (reek)</summary>

            #{lines}

            </details>
          MD
        end
      end

      flog_worse = (pr_result[:abc_method_average] || 0) > (base_result[:abc_method_average] || 0)
      if flog_worse
        base_flog = (base_result[:flog_files] || []).each_with_object({}) { |h, m| m[h[:file]] = h[:score] }
        worse_flog = (pr_result[:flog_files] || []).select { |h| h[:score] > (base_flog[h[:file]] || 0.0) }
        unless worse_flog.empty?
          lines = worse_flog.map { |h| "- `#{h[:file]}` — score: #{h[:score]} (+#{(h[:score] - (base_flog[h[:file]] || 0.0)).round(2)})" }.join("\n")
          sections << <<~MD
            <details>
            <summary>Files with higher complexity than base (flog)</summary>

            #{lines}

            </details>
          MD
        end
      end

      flay_worse = (pr_result[:similarity_score] || 0) > (base_result[:similarity_score] || 0)
      if flay_worse && (pr_result[:flay_blocks] || []).any?
        block_lines = (pr_result[:flay_blocks] || []).each_with_index.map do |block, i|
          locs = block[:locations].map { |l| "- `#{l[:file]}` (line #{l[:line]})" }.join("\n")
          "**Block #{i + 1}** — similarity mass: #{block[:mass]}\n#{locs}"
        end.join("\n\n")
        sections << <<~MD
          <details>
          <summary>New/worsened duplication (flay)</summary>

          #{block_lines}

          </details>
        MD
      end

      sections.join
    end

    private_class_method :format_file_breakdown
  end
end
