# frozen_string_literal: true

# Background job for calculating word complexity scores
class ComplexityCalculationJob < ApplicationJob
  queue_as :default

  # Performs the complexity calculation job
  #
  # @param job_id [String] job identifier
  #
  # @return [void]
  #
  # @example perform('abc123')
  # @example_return nil
  def perform(job_id)
    log(:info, message: 'Start of word complexity calculation', job_id:)

    complexity_job = ComplexityScore.find_by(job_id:)
    return if complexity_job.blank?

    complexity_job.mark_as_in_progress!
    words = complexity_job.words_array

    calculator = Complexity::CalculatorService.new
    scores = calculator.calculate_complexity_scores(words)

    complexity_job.mark_as_completed!(scores)
    log(:info, message: 'Word complexity calculation completed', job_id:, words_count: words.size)
  rescue StandardError => e
    log(:error, message: 'Error during word complexity calculation', job_id:, error: e.message)
    complexity_job&.mark_as_failed!(e.message)

    raise e unless retryable_error?(e)

    ComplexityCalculationJob.set(wait: 5.minutes).perform_later(job_id)
  end

  private

  # Checks if the error is retryable
  #
  # @param error [StandardError] error to check
  #
  # @return [Boolean] true if the error is retryable
  #
  # @example retryable_error?(Faraday::Error)
  # @example_return true
  def retryable_error?(error)
    case error
    when Faraday::Error, Timeout::Error, Net::ReadTimeout
      true
    else
      false
    end
  end
end
