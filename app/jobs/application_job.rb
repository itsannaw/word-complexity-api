# frozen_string_literal: true

# Base job class
class ApplicationJob < ActiveJob::Base
  # Logs a message
  #
  # @param type [Symbol] - log type (:info, :error, :warn)
  # @param data [Hash] - data for logging
  #
  # @example log(:info, {message: 'Completion of payment for transaction', transaction:})
  # @example log(:error, {message: 'Payment is being processed', transaction:})
  def log(type, data)
    Rails.logger.send(type, data)
  end
end
