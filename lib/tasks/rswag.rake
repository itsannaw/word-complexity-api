# frozen_string_literal: true

namespace :rswag do
  namespace :specs do
    desc 'Generate Swagger JSON files from integration specs'
    task swaggerize: :environment do
      # Run the specs with SwaggerFormatter
      RSpec::Core::RakeTask.new(:swaggerize) do |t|
        t.pattern = 'spec/requests/**/*_spec.rb, spec/api/**/*_spec.rb, spec/integration/**/*_spec.rb'
        t.rspec_opts = '--format Rswag::Specs::SwaggerFormatter'
      end
    end
  end
end
