# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Complexity::CalculatorService do
  let(:service) { described_class.new }

  let(:api_response) do
    [
      {
        'meanings' => [
          {
            'definitions' => [
              { 'definition' => 'feeling or showing pleasure', 'synonyms' => %w[joyful cheerful],
                'antonyms' => ['sad'] }
            ]
          }
        ]
      }
    ]
  end

  before do
    allow(service).to receive(:fetch_word_data).and_return(api_response)
  end

  describe '#calculate_complexity_scores' do
    subject(:result) { service.calculate_complexity_scores(words) }

    context 'with single word' do
      let(:words) { ['happy'] }

      it 'returns hash with complexity score' do
        expect(result).to be_a(Hash)
        expect(result).to have_key('happy')
        expect(result['happy']).to be_a(Float)
      end

      it 'returns score within valid range' do
        expect(result['happy']).to be >= 0.0
      end
    end

    context 'with multiple words' do
      let(:words) { %w[happy sad beautiful] }

      it 'returns hash with all words' do
        expect(result.keys).to match_array(words)
      end

      it 'calculates scores for all words' do
        expect(result['happy']).to be_a(Float)
        expect(result['sad']).to be_a(Float)
        expect(result['beautiful']).to be_a(Float)
      end

      it 'returns all scores as positive numbers' do
        result.each_value do |score|
          expect(score).to be >= 0.0
        end
      end
    end

    context 'with empty array' do
      let(:words) { [] }

      it 'returns empty hash' do
        expect(result).to eq({})
      end
    end
  end

  describe '#calculate_for_word' do
    subject(:score) { service.send(:calculate_for_word, word) }

    context 'with valid API response' do
      let(:word) { 'hello' }

      it 'returns a float score' do
        expect(score).to be_a(Float)
      end

      it 'returns a positive score' do
        expect(score).to be >= 0.0
      end
    end

    context 'when API returns no data' do
      let(:word) { 'nonexistentword' }

      before do
        allow(service).to receive(:fetch_word_data).and_return(nil)
      end

      it 'returns 0.0' do
        expect(score).to eq(0.0)
      end
    end

    context 'when API returns empty meanings' do
      let(:word) { 'test' }

      before do
        allow(service).to receive(:fetch_word_data).and_return([{ 'meanings' => [] }])
      end

      it 'returns 0.0' do
        expect(score).to eq(0.0)
      end
    end
  end
end
