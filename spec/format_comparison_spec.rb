# frozen_string_literal: true

require "code_quality_score/format_comparison"

RSpec.describe CodeQualityScore::FormatComparison do
  let(:base_result) do
    {
      similarity_score: 1.0,
      abc_method_average: 1.0,
      code_smells_per_file: 1.0,
      total_score: 3.0,
      total_file_count: 2,
      ruby_file_count: 2,
      reek_files: [{ file: "app/models/user.rb", smells: 3 }],
      flog_files: [{ file: "app/models/user.rb", score: 10.0 }],
      flay_blocks: [{ mass: 30, locations: [{ file: "app/models/user.rb", line: 1 }, { file: "lib/foo.rb", line: 5 }] }]
    }
  end

  let(:worse_pr_result) do
    {
      similarity_score: 2.0,
      abc_method_average: 2.0,
      code_smells_per_file: 2.0,
      total_score: 6.0,
      total_file_count: 2,
      ruby_file_count: 2,
      reek_files: [{ file: "app/models/user.rb", smells: 5 }, { file: "lib/bar.rb", smells: 2 }],
      flog_files: [{ file: "app/models/user.rb", score: 20.0 }, { file: "lib/bar.rb", score: 5.0 }],
      flay_blocks: [{ mass: 50, locations: [{ file: "app/models/user.rb", line: 1 }, { file: "lib/foo.rb", line: 5 }] }]
    }
  end

  let(:better_pr_result) do
    {
      similarity_score: 0.5,
      abc_method_average: 0.5,
      code_smells_per_file: 0.5,
      total_score: 1.5,
      total_file_count: 2,
      ruby_file_count: 2,
      reek_files: [{ file: "app/models/user.rb", smells: 1 }],
      flog_files: [{ file: "app/models/user.rb", score: 5.0 }],
      flay_blocks: []
    }
  end

  describe ".format_as_markdown" do
    context "when the PR is worse than base" do
      subject(:output) { described_class.format_as_markdown(base_result, worse_pr_result) }

      it "includes a collapsible reek section listing files with more smells" do
        expect(output).to include("<details>")
        expect(output).to include("Files with more code smells than base (reek)")
        expect(output).to include("`app/models/user.rb` — 5 smells")
        expect(output).to include("`lib/bar.rb` — 2 smells")
      end

      it "does not list reek files that stayed the same or improved" do
        expect(output).not_to include("— 3 smells")
      end

      it "includes a collapsible flog section listing files with higher complexity" do
        expect(output).to include("Files with higher complexity than base (flog)")
        expect(output).to include("`app/models/user.rb` — score: 20.0")
        expect(output).to include("`lib/bar.rb` — score: 5.0")
      end

      it "includes a collapsible flay section when similarity score worsened" do
        expect(output).to include("New/worsened duplication (flay)")
        expect(output).to include("similarity mass: 50")
        expect(output).to include("`app/models/user.rb` (line 1)")
        expect(output).to include("`lib/foo.rb` (line 5)")
      end

      it "wraps sections in details/summary tags" do
        expect(output).to include("<details>")
        expect(output).to include("<summary>")
        expect(output).to include("</details>")
      end
    end

    context "when the PR is better than base" do
      subject(:output) { described_class.format_as_markdown(base_result, better_pr_result) }

      it "omits all details sections" do
        expect(output).not_to include("<details>")
      end
    end
  end
end
