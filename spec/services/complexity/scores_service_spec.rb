# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Complexity::ScoresService do
  describe '.create_job' do
    subject(:result) { described_class.create_job(words) }

    context 'with valid words array' do
      let(:words) { %w[happy sad] }

      before do
        allow(ComplexityCalculationJob).to receive(:perform_later)
      end

      it 'creates a new ComplexityScore record' do
        expect { result }.to change(ComplexityScore, :count).by(1)
      end

      it 'returns success response with job_id' do
        expect(result[:status]).to eq(:accepted)
        expect(result[:data]).to have_key(:job_id)
        expect(result[:data][:job_id]).to be_present
      end

      it 'sets status to pending' do
        result
        job = ComplexityScore.last
        expect(job.status).to eq('pending')
      end

      it 'saves words array' do
        result
        job = ComplexityScore.last
        expect(job.words_array).to eq(words)
      end

      it 'schedules background job' do
        result
        expect(ComplexityCalculationJob).to have_received(:perform_later)
      end

      it 'generates hex ID for job_id' do
        expect(result[:data][:job_id]).to match(/\A[0-9a-f]{12}\z/)
      end
    end

    context 'with empty array' do
      let(:words) { [] }

      it 'does not create a record' do
        expect { result }.not_to change(ComplexityScore, :count)
      end

      it 'returns bad request status' do
        expect(result[:status]).to eq(:bad_request)
      end

      it 'returns error message' do
        expect(result[:data][:errors]).to include('Words array cannot be empty')
      end
    end

    context 'with nil words' do
      let(:words) { nil }

      it 'does not create a record' do
        expect { result }.not_to change(ComplexityScore, :count)
      end

      it 'returns bad request status' do
        expect(result[:status]).to eq(:bad_request)
      end

      it 'returns error message' do
        expect(result[:data][:errors]).to include('Words array cannot be empty')
      end
    end

    context 'with non-array input' do
      let(:words) { 'not an array' }

      it 'does not create a record' do
        expect { result }.not_to change(ComplexityScore, :count)
      end

      it 'returns bad request status' do
        expect(result[:status]).to eq(:bad_request)
      end
    end

    context 'with non-string elements in array' do
      let(:words) { ['happy', 123, 'sad', nil] }

      it 'does not create a record' do
        expect { result }.not_to change(ComplexityScore, :count)
      end

      it 'returns bad request status' do
        expect(result[:status]).to eq(:bad_request)
      end

      it 'returns error message' do
        expect(result[:data][:errors]).to include('All words must be strings')
      end
    end

    context 'when database error occurs' do
      let(:words) { %w[happy sad] }

      before do
        allow(ComplexityScore).to receive(:create!).and_raise(ActiveRecord::RecordInvalid)
      end

      it 'returns internal server error status' do
        expect(result[:status]).to eq(:internal_server_error)
      end

      it 'returns error message' do
        expect(result[:data]).to have_key(:errors)
        expect(result[:data][:errors]).to be_an(Array)
      end
    end
  end

  describe '.get_job' do
    subject(:result) { described_class.get_job(job_id) }

    let(:job_id) { complexity_score.job_id }

    context 'with pending status' do
      let(:complexity_score) { create(:complexity_score) }

      it 'returns ok status' do
        expect(result[:status]).to eq(:ok)
      end

      it 'returns job status' do
        expect(result[:data][:status]).to eq('pending')
      end

      it 'does not include result' do
        expect(result[:data]).not_to have_key(:result)
      end
    end

    context 'with in_progress status' do
      let(:complexity_score) { create(:complexity_score, :in_progress) }

      it 'returns ok status' do
        expect(result[:status]).to eq(:ok)
      end

      it 'returns job status' do
        expect(result[:data][:status]).to eq('in_progress')
      end

      it 'does not include result' do
        expect(result[:data]).not_to have_key(:result)
      end
    end

    context 'with completed status' do
      let(:complexity_score) { create(:complexity_score, :completed) }

      it 'returns ok status' do
        expect(result[:status]).to eq(:ok)
      end

      it 'returns job status' do
        expect(result[:data][:status]).to eq('completed')
      end

      it 'includes result hash' do
        expect(result[:data][:result]).to eq({ 'happy' => 3.5, 'sad' => 2.8, 'angry' => 3.2 })
      end
    end

    context 'with failed status' do
      let(:complexity_score) { create(:complexity_score, :failed) }

      it 'returns ok status' do
        expect(result[:status]).to eq(:ok)
      end

      it 'returns job status' do
        expect(result[:data][:status]).to eq('failed')
      end

      it 'includes error message' do
        expect(result[:data][:error]).to eq('API error occurred')
      end
    end

    context 'when job does not exist' do
      let(:job_id) { 'nonexistent-job-id' }

      it 'returns not found status' do
        expect(result[:status]).to eq(:not_found)
      end

      it 'returns error message' do
        expect(result[:data][:error]).to eq('Job not found')
      end
    end
  end
end
