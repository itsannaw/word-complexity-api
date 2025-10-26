# frozen_string_literal: true

require 'swagger_helper'

RSpec.describe 'Complexity Scores API', type: :request do
  path '/complexity-score' do
    post 'Creates a complexity calculation job' do
      tags 'Complexity Scores'
      description 'Creates a new background job to calculate complexity scores for the provided words'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :complexity_score, in: :body, schema: {
        type: :object,
        properties: {
          words: {
            type: :array,
            items: { type: :string },
            description: 'Array of words to analyze for complexity',
            example: ['happy', 'sad', 'beautiful', 'ugly']
          }
        },
        required: ['words']
      }

      response '202', 'Job created successfully' do
        schema type: :object,
               properties: {
                 job_id: {
                   type: :string,
                   description: 'Unique identifier for the job',
                   example: 'a1b2c3d4e5f6'
                 }
               }

        let(:complexity_score) { { words: ['happy', 'sad', 'beautiful', 'ugly'] } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to have_key('job_id')
          expect(data['job_id']).to be_present
        end
      end

      response '400', 'Bad request - invalid input' do
        schema '$ref' => '#/components/schemas/Error'

        context 'when words array is empty' do
          let(:complexity_score) { { words: [] } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include('Words array cannot be empty')
        end
        end

        context 'when words parameter is missing' do
          let(:complexity_score) { {} }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors']).to include('Words array cannot be empty')
          end
        end

        context 'when words is not an array' do
          let(:complexity_score) { { words: 'not an array' } }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors']).to include('Words array cannot be empty')
          end
        end

        context 'when words contain non-string elements' do
          let(:complexity_score) { { words: ['happy', 123, 'sad'] } }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['errors']).to include('All words must be strings')
          end
        end
      end

      response '500', 'Internal server error' do
        schema '$ref' => '#/components/schemas/Error'

        let(:complexity_score) { { words: ['valid', 'words'] } }

        before do
          allow(Complexity::ScoresService).to receive(:create_job).and_return({ data: { errors: ['Database error'] }, status: :internal_server_error })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['errors']).to include('Database error')
        end
      end
    end
  end

  path '/complexity-score/{job_id}' do
    get 'Retrieves job status and results' do
      tags 'Complexity Scores'
      description 'Retrieves the current status and results of a complexity calculation job'
      produces 'application/json'
      parameter name: :job_id, in: :path, type: :string, description: 'Job identifier returned from the create endpoint'

      response '200', 'Job status retrieved successfully' do
        schema oneOf: [
          {
            type: :object,
            properties: {
              status: {
                type: :string,
                enum: %w[pending in_progress],
                description: 'Current job status'
              }
            }
          },
          {
            type: :object,
            properties: {
              status: {
                type: :string,
                enum: ['completed'],
                description: 'Job completed successfully'
              },
              result: {
                type: :object,
                additionalProperties: {
                  type: :number
                },
                description: 'Complexity scores for each word',
                example: {
                  happy: 3.5,
                  sad: 2.8,
                  beautiful: 4.2,
                  ugly: 2.1
                }
              }
            }
          },
          {
            type: :object,
            properties: {
              status: {
                type: :string,
                enum: ['failed'],
                description: 'Job failed'
              },
              error: {
                type: :string,
                description: 'Error message'
              }
            }
          }
        ]

        context 'when job is pending' do
          let(:job_id) { 'pending_job_id' }
          let!(:complexity_score) { create(:complexity_score, job_id: job_id, status: 'pending') }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['status']).to eq('pending')
          end
        end

        context 'when job is in progress' do
          let(:job_id) { 'in_progress_job_id' }
          let!(:complexity_score) { create(:complexity_score, :in_progress, job_id: job_id) }

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['status']).to eq('in_progress')
          end
        end

        context 'when job is completed' do
          let(:job_id) { 'completed_job_id' }
          let!(:complexity_score) do
            create(:complexity_score, 
                   :completed,
                   job_id: job_id)
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['status']).to eq('completed')
            expect(data['result']).to be_a(Hash)
          end
        end

        context 'when job failed' do
          let(:job_id) { 'failed_job_id' }
          let!(:complexity_score) do
            create(:complexity_score, 
                   :failed,
                   job_id: job_id)
          end

          run_test! do |response|
            data = JSON.parse(response.body)
            expect(data['status']).to eq('failed')
            expect(data['error']).to be_present
          end
        end
      end

      response '404', 'Job not found' do
        schema '$ref' => '#/components/schemas/Error'

        let(:job_id) { 'nonexistent_job_id' }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['error']).to eq('Job not found')
        end
      end
    end
  end
end
