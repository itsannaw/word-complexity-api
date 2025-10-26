# frozen_string_literal: true

Rswag::Ui.configure do |c|
  # List the Swagger endpoints that you want to be documented. As the examples above
  # the OpenAPI/Swagger spec will be fetched from these endpoints
  # In the background, the specs will be transformed to JSON and then displayed
  # in the Swagger UI

  # Fetch the OpenAPI/Swagger spec from a single endpoint
  c.openapi_endpoint '/api-docs/v1/swagger.yaml', 'API V1 Docs'

  # Add Basic Auth in case your API is private
  # c.basic_auth_enabled = true
  # c.basic_auth_credentials 'username', 'password'
end
