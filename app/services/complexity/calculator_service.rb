# frozen_string_literal: true

require 'net/http'
require 'json'

module Complexity
  class CalculatorService
    BASE_URL = Settings.external_apis.dictionary.base_url

    # Calculates complexity scores for an array of words
    #
    # @param words [Array<String>] array of words to analyze
    #
    # @return [Hash<String, Float>] word complexity scores
    #
    # @example calculate_complexity_scores(['happy', 'sad'])
    # @example_return { 'happy' => 3.5, 'sad' => 2.8 }
    def calculate_complexity_scores(words)
      results = {}

      words.each do |word|
        score = calculate_for_word(word)
        results[word] = score
      end

      results
    end

    private

    # Calculates the complexity score for a single word
    #
    # @param word [String] word to analyze
    #
    # @return [Float] word complexity score
    #
    # @example calculate_for_word('happy')
    # @example_return 3.5
    def calculate_for_word(word)
      response = fetch_word_data(word)
      return 0.0 unless response.is_a?(Array) && response.first['meanings']

      meanings = response.first['meanings']
      return 0.0 if meanings.empty?

      total_definitions = meanings.sum { |m| (m['definitions'] || []).size }
      return 0.0 if total_definitions.zero?

      synonyms = meanings.flat_map { |m| m['synonyms'] || [] }.uniq
      antonyms = meanings.flat_map { |m| m['antonyms'] || [] }.uniq

      score = (synonyms.size + antonyms.size).to_f / total_definitions
      score.round(2)
    rescue StandardError
      0.0
    end

    # Fetches word data from the dictionary API
    #
    # @param word [String] word to analyze
    #
    # @return [Hash] word data
    #
    # @example fetch_word_data('happy')
    # @example_return { 'definitions' => [{ 'definition' => 'happy' }] }
    def fetch_word_data(word)
      uri = URI("#{BASE_URL}/#{URI.encode_www_form_component(word)}")
      response = Net::HTTP.get_response(uri)
      return nil unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end
  end
end
