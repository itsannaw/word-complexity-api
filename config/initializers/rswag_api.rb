# frozen_string_literal: true

Rswag::Api.configure do |c|
  # Specify a root folder where Swagger JSON files are located
  # This is used by the Swagger middleware to serve requests for API descriptions
  # NOTE: If you're using rswag-specs to generate Swagger, you'll need to ensure
  # that it's configured to generate files in the same folder
  c.openapi_root = Rails.root.join('swagger').to_s

  # Inject a lambda function to alter the returned Swagger prior to serialization
  # The function will have access to the rack env, the definition object being processed, and the original Swagger object
  # For example, you could leverage this to dynamically add new information to the Swagger definition
  # or to remove unwanted parts of the API
  #
  # c.swagger_filter = lambda { |swagger, env| swagger }
end
