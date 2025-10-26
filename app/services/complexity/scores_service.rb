# frozen_string_literal: true

module Complexity
  # Service for managing complexity score calculations
  class ScoresService
    # Creates a new complexity calculation job
    #
    # @param words [Array<String>] array of words to analyze
    #
    # @return [Hash] job creation response with status 202
    #
    # @example_request ['happy', 'sad']
    # @example_response 202 { "job_id": "abc123" }
    # @return [Hash]
    def self.create_job(words)
      unless words.is_a?(Array) && words.any?
        return { data: { errors: ['Words array cannot be empty'] }, status: :bad_request }
      end

      unless words.all? { |word| word.is_a?(String) }
        return { data: { errors: ['All words must be strings'] }, status: :bad_request }
      end

      job_id = SecureRandom.hex(6)

      job = ComplexityScore.create!(
        job_id: job_id,
        status: 'pending',
        words_array: words
      )

      ComplexityCalculationJob.perform_later(job_id)

      { data: { job_id: job.job_id }, status: :accepted }
    rescue StandardError => e
      { data: { errors: [e.message] }, status: :internal_server_error }
    end

    # Retrieves the status of a complexity calculation job
    #
    # @param job_id [String] job identifier
    #
    # @return [Hash] job status response with status 200
    #
    # @example_request 'abc123'
    # @example_response 200 { "status": "pending" }
    #
    # @example_request 'abc123'
    # @example_response 200 { "status": "completed", "result": { "happy": 3.5, "sad": 2.8 } }
    # @return [Hash]
    def self.get_job(job_id)
      job = ComplexityScore.find_by(job_id:)
      return { data: { error: 'Job not found' }, status: :not_found } unless job

      case job.status
      when 'pending', 'in_progress'
        { data: { status: job.status }, status: :ok }
      when 'completed'
        { data: { status: 'completed', result: job.result_hash }, status: :ok }
      when 'failed'
        { data: { status: 'failed', error: job.result }, status: :ok }
      else
        { data: { status: 'unknown' }, status: :ok }
      end
    end
  end
end
