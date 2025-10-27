# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComplexityScore, type: :model do
  describe 'validations' do
    subject { build(:complexity_score) }

    it { is_expected.to validate_presence_of(:job_id) }
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:words) }
    it { is_expected.to validate_uniqueness_of(:job_id) }
    it { is_expected.to validate_inclusion_of(:status).in_array(%w[pending in_progress completed failed]) }
  end

  describe 'database columns' do
    subject(:model) { described_class.new }

    it {
      expect(model).to have_db_column(:id)
      expect(model).to have_db_column(:job_id)
      expect(model).to have_db_column(:status)
      expect(model).to have_db_column(:words)
      expect(model).to have_db_column(:result)
      expect(model).to have_db_column(:created_at)
      expect(model).to have_db_column(:updated_at)
    }
  end

  describe 'indexes' do
    subject(:model) { described_class.new }

    it {
      expect(model).to have_db_index(:job_id).unique(true)
      expect(model).to have_db_index(:status)
    }
  end

  describe '#words_array' do
    let(:complexity_score) { create(:complexity_score) }

    context 'when words is valid JSON' do
      it 'returns parsed array of words' do
        expect(complexity_score.words_array).to eq(%w[happy sad angry])
      end
    end

    context 'when words is invalid JSON' do
      before do
        complexity_score.words = 'invalid json'
        complexity_score.save(validate: false)
      end

      it 'returns empty array' do
        expect(complexity_score.words_array).to eq([])
      end
    end
  end

  describe '#words_array=' do
    let(:complexity_score) { build(:complexity_score) }

    it 'converts array to JSON string' do
      complexity_score.words_array = %w[test words]
      expect(complexity_score.words).to eq(%w[test words].to_json)
    end
  end

  describe '#result_hash' do
    context 'when result is nil' do
      let(:complexity_score) { create(:complexity_score, result: nil) }

      it 'returns empty hash' do
        expect(complexity_score.result_hash).to eq({})
      end
    end

    context 'when result is valid JSON' do
      let(:complexity_score) { create(:complexity_score, :completed) }

      it 'returns parsed hash' do
        expect(complexity_score.result_hash).to eq({ 'happy' => 3.5, 'sad' => 2.8, 'angry' => 3.2 })
      end
    end

    context 'when result is invalid JSON' do
      let(:complexity_score) { create(:complexity_score, result: 'invalid json') }

      it 'returns empty hash' do
        expect(complexity_score.result_hash).to eq({})
      end
    end
  end

  describe '#result_hash=' do
    let(:complexity_score) { build(:complexity_score) }

    it 'converts hash to JSON string' do
      complexity_score.result_hash = { 'word' => 5.0 }
      expect(complexity_score.result).to eq({ 'word' => 5.0 }.to_json)
    end
  end

  describe '#mark_as_in_progress!' do
    let(:complexity_score) { create(:complexity_score, status: 'pending') }

    it 'updates status to in_progress' do
      expect { complexity_score.mark_as_in_progress! }
        .to change(complexity_score, :status).from('pending').to('in_progress')
    end

    it 'returns true' do
      expect(complexity_score.mark_as_in_progress!).to be true
    end
  end

  describe '#mark_as_completed!' do
    let(:complexity_score) { create(:complexity_score, :in_progress) }
    let(:scores) { { 'happy' => 3.5, 'sad' => 2.8 } }

    it 'updates status to completed' do
      expect { complexity_score.mark_as_completed!(scores) }
        .to change(complexity_score, :status).from('in_progress').to('completed')
    end

    it 'saves the scores' do
      complexity_score.mark_as_completed!(scores)
      expect(complexity_score.result_hash).to eq(scores)
    end

    it 'returns true' do
      expect(complexity_score.mark_as_completed!(scores)).to be true
    end
  end

  describe '#mark_as_failed!' do
    let(:complexity_score) { create(:complexity_score, :in_progress) }
    let(:error_message) { 'API error occurred' }

    it 'updates status to failed' do
      expect { complexity_score.mark_as_failed!(error_message) }
        .to change(complexity_score, :status).from('in_progress').to('failed')
    end

    it 'saves the error message' do
      complexity_score.mark_as_failed!(error_message)
      expect(complexity_score.result).to eq(error_message)
    end

    it 'returns true' do
      expect(complexity_score.mark_as_failed!(error_message)).to be true
    end
  end
end
