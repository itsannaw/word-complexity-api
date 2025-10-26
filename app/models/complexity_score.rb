# frozen_string_literal: true

# Model representing complexity scores calculation record
class ComplexityScore < ApplicationRecord
  validates :job_id, presence: true, uniqueness: true
  validates :status, presence: true, inclusion: { in: %w[pending in_progress completed failed] }
  validates :words, presence: true

  # Converts JSON string to array of words
  #
  # @return [Array<String>] array of words to analyze
  #
  # @example words_array
  # @example_return ['happy', 'sad', 'beautiful']
  #
  # @example words_array (with invalid JSON)
  # @example_return []
  def words_array
    JSON.parse(words)
  rescue JSON::ParserError
    []
  end

  # Sets words from array, converting to JSON
  #
  # @param array [Array<String>] array of words
  #
  # @return [void]
  #
  # @example words_array = ['happy', 'sad']
  def words_array=(array)
    self.words = array.to_json
  end

  # Converts JSON result to hash of complexity scores
  #
  # @return [Hash<String, Float>] word complexity scores
  #
  # @example result_hash
  # @example_return { 'happy' => 3.5, 'sad' => 2.8 }
  #
  # @example result_hash (with invalid JSON)
  # @example_return {}
  def result_hash
    return {} if result.blank?

    JSON.parse(result)
  rescue JSON::ParserError
    {}
  end

  # Sets result from hash, converting to JSON
  #
  # @param hash [Hash<String, Float>] word complexity scores
  #
  # @return [void]
  #
  # @example result_hash = { 'happy' => 3.5, 'sad' => 2.8 }
  def result_hash=(hash)
    self.result = hash.to_json
  end

  # Marks job as in progress
  #
  # @return [Boolean] true if update was successful
  #
  # @example mark_as_in_progress!
  # @example_return true
  def mark_as_in_progress!
    update!(status: 'in_progress')
  end

  # Marks job as completed with complexity scores
  #
  # @param scores [Hash<String, Float>] complexity scores for each word
  #
  # @return [Boolean] true if update was successful
  #
  # @example mark_as_completed!({ 'happy' => 3.5, 'sad' => 2.8 })
  # @example_return true
  def mark_as_completed!(scores)
    update!(status: 'completed', result_hash: scores)
  end

  # Marks job as failed with error message
  #
  # @param error_message [String] error description
  #
  # @return [Boolean] true if update was successful
  #
  # @example mark_as_failed!('Processing error')
  # @example_return true
  def mark_as_failed!(error_message)
    update!(status: 'failed', result: error_message)
  end
end
