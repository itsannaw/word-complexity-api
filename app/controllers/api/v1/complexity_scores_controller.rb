# frozen_string_literal: true

module Api
  module V1
    # Controller for managing complexity score calculations
    class ComplexityScoresController < BaseController
      # Creates a new complexity calculation job
      #
      # POST /api/v1/complexity-score
      # Accepts JSON array of words directly
      #
      # @return [JSON] job creation response with status 202
      #
      # @example_request ["happy", "sad"]
      # @example_response 202 { "job_id": "abc123" }
      #
      # @example_request []
      # @example_response 400 { "errors": ["Words array cannot be empty"] }
      def create
        response = Complexity::ScoresService.create_job(params[:words])

        render json: response[:data], status: response[:status]
      end

      # Retrieves the status and result of a complexity calculation job
      #
      # GET /api/v1/complexity-score/:job_id
      #
      # @param job_id [String] job identifier
      #
      # @return [JSON] job status and result
      #
      # @example_request GET /api/v1/complexity-score/abc123
      # @example_response 200 { "status": "completed", "result": { "happy": 3.5 } }
      #
      # @example_response 404 { "error": "Job not found" }
      def show
        response = Complexity::ScoresService.get_job(params[:job_id])

        render json: response[:data], status: response[:status]
      end
    end
  end
end
