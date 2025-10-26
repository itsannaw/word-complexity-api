# frozen_string_literal: true

source 'https://rubygems.org'

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem 'rails', '~> 8.0.1'
# Use sqlite3 as the database for Active Record
gem 'sqlite3', '~> 2.1'
# Use the Puma web server [https://github.com/puma/puma]
gem 'puma', '>= 5.0'

# HTTP client for external API calls
gem 'faraday'
gem 'faraday-retry'

# JSON parsing
gem 'oj'

# CORS support
gem 'rack-cors'

# Background jobs
gem 'solid_queue'

# Caching
gem 'solid_cache'

# Configuration management
gem 'config'

# Environment variables
gem 'dotenv'

# Parallel processing
gem 'concurrent-ruby'

# API documentation
gem 'rswag-api'
gem 'rswag-specs'
gem 'rswag-ui'

# Windows does not include zoneinfo files, so bundle the tzinfo-data gem
gem 'tzinfo-data', platforms: %i[windows jruby]

# Reduces boot times through caching; required in config/boot.rb
gem 'bootsnap', require: false

group :development, :test do
  # Debugging
  gem 'byebug'
  gem 'debug', platforms: %i[mri windows], require: 'debug/prelude'

  # Testing
  gem 'factory_bot_rails'
  gem 'faker'
  gem 'rspec-rails'
  gem 'vcr'
  gem 'webmock'

  # Code quality
  gem 'rubocop'
  gem 'rubocop-rails'
  gem 'rubocop-rspec'

  # Testing helpers
  gem 'shoulda-matchers'
end

group :development do
  # Use console on exceptions pages
  gem 'web-console'
end
