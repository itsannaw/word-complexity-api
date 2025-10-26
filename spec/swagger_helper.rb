# frozen_string_literal: true

require 'rails_helper'

RSpec.configure do |config|
  # Specify a root folder where Swagger JSON files are generated
  # NOTE: If you're using the rswag-api to serve API descriptions, you'll need
  # to ensure that it's configured to serve Swagger from the same folder
  config.openapi_root = Rails.root.join('swagger').to_s

  # Define one or more Swagger documents and provide global metadata for each one
  # When you run the 'rswag:specs:swaggerize' rake task, the complete Swagger will
  # be generated at the provided relative path under openapi_root
  # For example, if you have 'spec/requests/api/v1/users_spec.rb' and you want to
  # generate 'swagger/v1/users.json', you would set:
  #   config.openapi_specs = {
  #     'v1/users.json' => {
  #       openapi: '3.0.1',
  #       info: {
  #         title: 'Users API',
  #         version: 'v1'
  #       },
  #       paths: {},
  #       servers: [
  #         {
  #           url: 'https://{defaultHost}',
  #           variables: {
  #             defaultHost: {
  #               default: 'localhost:3000'
  #             }
  #           }
  #         }
  #       ]
  #     }
  #   }
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'Word Complexity API',
        version: 'v1',
        description: 'API for calculating word complexity scores using background job processing'
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Development server'
        }
      ],
      components: {
        schemas: {
          Error: {
            type: 'object',
            properties: {
              error: {
                type: 'string',
                description: 'Error message'
              },
              errors: {
                type: 'array',
                items: {
                  type: 'string'
                },
                description: 'List of error messages'
              }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file. Defaults to 'json'
  config.openapi_format = :yaml
end
