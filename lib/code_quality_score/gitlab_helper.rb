# frozen_string_literal: true

require "faraday"

module CodeQualityScore
  class GitlabHelper
    def initialize(config)
      @gitlab_url = config[:gitlab_url]
      @project_id = config[:project_id]
      @merge_request_id = config[:merge_request_id]
      @access_token = config[:access_token]
    end

    def self.upsert_gitlab_comment(message)
      


    end
  end
end
