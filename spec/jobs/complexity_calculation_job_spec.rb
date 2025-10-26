# frozen_string_literal: true

require 'rails_helper'

RSpec.describe ComplexityCalculationJob, type: :job do
  let(:job) { described_class.new }
  let(:complexity_score) { create(:complexity_score, status: 'pending') }
  let(:job_id) { complexity_score.job_id }

  # Mock log method as it's used in the job
  before do
    allow(job).to receive(:log)
  end

  describe '#perform' do
    context 'with valid job' do
      let(:calculator) { instance_double(Complexity::CalculatorService) }
      let(:scores) { { 'happy' => 3.5, 'sad' => 2.8, 'angry' => 3.2 } }

      before do
        allow(Complexity::CalculatorService).to receive(:new).and_return(calculator)
        allow(calculator).to receive(:calculate_complexity_scores).and_return(scores)
      end

      it 'marks job as in_progress' do
        expect { job.perform(job_id) }
          .to change { complexity_score.reload.status }.from('pending').to('completed')
      end

      it 'calculates complexity scores' do
        job.perform(job_id)
        expect(calculator).to have_received(:calculate_complexity_scores).with(complexity_score.words_array)
      end

      it 'marks job as completed with scores' do
        job.perform(job_id)
        complexity_score.reload
        expect(complexity_score.status).to eq('completed')
        expect(complexity_score.result_hash).to eq(scores)
      end

      it 'logs start message' do
        job.perform(job_id)
        expect(job).to have_received(:log).with(:info, hash_including(message: 'Start of word complexity calculation'))
      end

      it 'logs completion message' do
        job.perform(job_id)
        expect(job).to have_received(:log).with(:info, hash_including(message: 'Word complexity calculation completed'))
      end
    end

    context 'when job does not exist' do
      let(:job_id) { 'nonexistent-job-id' }

      it 'returns early without error' do
        expect { job.perform(job_id) }.not_to raise_error
      end

      it 'logs start message' do
        job.perform(job_id)
        expect(job).to have_received(:log).with(:info, hash_including(message: 'Start of word complexity calculation'))
      end
    end

    context 'when calculation raises error' do
      let(:calculator) { instance_double(Complexity::CalculatorService) }
      let(:error_message) { 'Calculation failed' }

      before do
        allow(Complexity::CalculatorService).to receive(:new).and_return(calculator)
        allow(calculator).to receive(:calculate_complexity_scores).and_raise(StandardError, error_message)
      end

      it 'marks job as failed' do
        expect { job.perform(job_id) }.to raise_error(StandardError)
        complexity_score.reload
        expect(complexity_score.status).to eq('failed')
      end

      it 'saves error message' do
        expect { job.perform(job_id) }.to raise_error(StandardError)
        complexity_score.reload
        expect(complexity_score.result).to eq(error_message)
      end

      it 'logs error message' do
        expect { job.perform(job_id) }.to raise_error(StandardError)
        expect(job).to have_received(:log).with(:error,
                                                hash_including(message: 'Error during word complexity calculation'))
      end

      it 're-raises the error' do
        expect { job.perform(job_id) }.to raise_error(StandardError, error_message)
      end
    end

    context 'when network error occurs' do
      let(:calculator) { instance_double(Complexity::CalculatorService) }
      let(:error) { Faraday::Error.new('Network timeout') }

      before do
        allow(Complexity::CalculatorService).to receive(:new).and_return(calculator)
        allow(calculator).to receive(:calculate_complexity_scores).and_raise(error)
        allow(described_class).to receive(:set).and_return(described_class)
        allow(described_class).to receive(:perform_later)
      end

      it 'schedules retry after 5 minutes' do
        job.perform(job_id)
        expect(described_class).to have_received(:set).with(wait: 5.minutes)
        expect(described_class).to have_received(:perform_later).with(job_id)
      end

      it 'marks job as failed' do
        job.perform(job_id)
        complexity_score.reload
        expect(complexity_score.status).to eq('failed')
      end
    end

    context 'when timeout error occurs' do
      let(:calculator) { instance_double(Complexity::CalculatorService) }
      let(:error) { Timeout::Error.new('Request timeout') }

      before do
        allow(Complexity::CalculatorService).to receive(:new).and_return(calculator)
        allow(calculator).to receive(:calculate_complexity_scores).and_raise(error)
        allow(described_class).to receive(:set).and_return(described_class)
        allow(described_class).to receive(:perform_later)
      end

      it 'schedules retry after 5 minutes' do
        job.perform(job_id)
        expect(described_class).to have_received(:set).with(wait: 5.minutes)
        expect(described_class).to have_received(:perform_later).with(job_id)
      end
    end
  end

  describe '#retryable_error?' do
    it 'returns true for Faraday::Error' do
      error = Faraday::Error.new('Network error')
      expect(job.send(:retryable_error?, error)).to be true
    end

    it 'returns true for Timeout::Error' do
      error = Timeout::Error.new
      expect(job.send(:retryable_error?, error)).to be true
    end

    it 'returns true for Net::ReadTimeout' do
      error = Net::ReadTimeout.new
      expect(job.send(:retryable_error?, error)).to be true
    end

    it 'returns false for StandardError' do
      error = StandardError.new('Generic error')
      expect(job.send(:retryable_error?, error)).to be false
    end

    it 'returns false for ArgumentError' do
      error = ArgumentError.new('Invalid argument')
      expect(job.send(:retryable_error?, error)).to be false
    end
  end
end
