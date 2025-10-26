# frozen_string_literal: true

# Controller for health check
class HealthController < ApplicationController
  def check
    render json: { status: 'ok', timestamp: Time.current }
  end
end
