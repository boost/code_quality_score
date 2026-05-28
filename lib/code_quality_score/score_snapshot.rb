# frozen_string_literal: true

module CodeQualityScore
  class ScoreSnapshot
    DEFAULT_SCORE_WEIGHTS = {
      similarity_score: 0.003,
      abc_method_average: 0.8,
      code_smells_per_file: 5
    }.freeze

    def initialize(repository_path:, score_weights: {})
      @repo_path = repository_path
      @score_weights = DEFAULT_SCORE_WEIGHTS.merge(score_weights)
    end

    def calculate_score
      folders = find_folders.join(' ')
      ruby_file_count = count_ruby_files(folders)

      flay_output = `flay #{folders}`
      flog_output = `flog #{folders}`
      reek_output = `reek #{folders}`

      result = {
        similarity_score: structural_similarity_score(flay_output),
        abc_method_average: abc_method_average_score(flog_output),
        code_smells_per_file: code_smells_per_file(reek_output, ruby_file_count),
        reek_files: parse_reek_files(reek_output),
        flog_files: parse_flog_files(flog_output),
        flay_blocks: parse_flay_blocks(flay_output)
      }

      result[:total_score] = (result[:similarity_score] + result[:abc_method_average] + result[:code_smells_per_file]).round(2)
      result[:total_file_count] = count_files(folders)
      result[:ruby_file_count] = ruby_file_count

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

    def count_ruby_files(folders)
      Integer(`find #{folders} -type f -name "*.rb" | wc -l`)
    end

    def structural_similarity_score(flay_output)
      score_line = flay_output.lines.first
      score_number = Float(score_line.split(" ").last).round(2)
      weighted_score = score_number * @score_weights[:similarity_score]
      weighted_score.round(2)
    end

    def abc_method_average_score(flog_output)
      score_line = flog_output.lines[1]
      score = Float(score_line.split(":").first).round(2)
      weighted_score = score * @score_weights[:abc_method_average]
      weighted_score.round(2)
    end

    def code_smells_per_file(reek_output, file_count)
      score_line = reek_output.lines.last
      score_number = Float(score_line.split(" ").first)
      score_per_file = (score_number / file_count).round(2)
      weighted_score = score_per_file * @score_weights[:code_smells_per_file]
      weighted_score.round(2)
    end

    def parse_reek_files(reek_output)
      reek_output.lines.each_with_object([]) do |line, arr|
        match = line.match(/^(.+\.rb) -- (\d+) warning/)
        arr << { file: normalize_path(match[1]), smells: match[2].to_i } if match
      end.sort_by { |h| -h[:smells] }
    end

    def parse_flog_files(flog_output)
      file_scores = Hash.new(0.0)
      flog_output.lines.each do |line|
        match = line.match(/^\s+([\d.]+):\s+\S+\s+(\S+\.rb):\d+/)
        file_scores[normalize_path(match[2])] += match[1].to_f if match
      end
      file_scores.map { |file, score| { file: file, score: score.round(2) } }
                 .sort_by { |h| -h[:score] }
    end

    def parse_flay_blocks(flay_output)
      blocks = []
      current_block = nil

      flay_output.lines.each do |line|
        if (match = line.match(/^\d+\).+mass = (\d+)/))
          blocks << current_block if current_block
          current_block = { mass: match[1].to_i, locations: [] }
        elsif current_block && (match = line.match(/^\s+(.+\.rb):(\d+)/))
          current_block[:locations] << { file: normalize_path(match[1]), line: match[2].to_i }
        end
      end
      blocks << current_block if current_block

      blocks.sort_by { |b| -b[:mass] }
    end

    def normalize_path(path)
      prefix = @repo_path.end_with?('/') ? @repo_path : "#{@repo_path}/"
      path.delete_prefix(prefix)
    end
  end
end
