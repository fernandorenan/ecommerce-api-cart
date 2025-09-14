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
  # By default, the operations defined in spec files are added to the first
  # document below. You can override this behavior by adding a openapi_spec tag to the
  # the root example_group in your specs, e.g. describe '...', openapi_spec: 'v2/swagger.json'
  config.openapi_specs = {
    'v1/swagger.yaml' => {
      openapi: '3.0.1',
      info: {
        title: 'E-commerce API',
        description: 'API para gerenciamento de produtos e carrinho de compras',
        version: 'v1',
        contact: {
          name: 'Suporte API',
          email: 'suporte@example.com'
        }
      },
      paths: {},
      servers: [
        {
          url: 'http://localhost:3000',
          description: 'Servidor de desenvolvimento'
        },
        {
          url: 'https://{defaultHost}',
          description: 'Servidor de produção',
          variables: {
            defaultHost: {
              default: 'api.example.com'
            }
          }
        }
      ],
      components: {
        schemas: {
          Product: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'Produto Exemplo' },
              price: { type: :number, format: :float, example: 29.99 },
              created_at: { type: :string, format: :datetime },
              updated_at: { type: :string, format: :datetime }
            },
            required: ['id', 'name', 'price']
          },
          CartItem: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              name: { type: :string, example: 'Produto Exemplo' },
              quantity: { type: :integer, example: 2 },
              unit_price: { type: :number, format: :float, example: 29.99 },
              total_price: { type: :number, format: :float, example: 59.98 }
            }
          },
          Cart: {
            type: :object,
            properties: {
              id: { type: :integer, example: 1 },
              products: {
                type: :array,
                items: { '$ref' => '#/components/schemas/CartItem' }
              },
              total_price: { type: :number, format: :float, example: 59.98 }
            }
          },
          Error: {
            type: :object,
            properties: {
              error: { type: :string, example: 'Mensagem de erro' }
            }
          }
        }
      }
    }
  }

  # Specify the format of the output Swagger file when running 'rswag:specs:swaggerize'.
  # The openapi_specs configuration option has the filename including format in
  # the key, this may want to be changed to avoid putting yaml in json files.
  # Defaults to json. Accepts ':json' and ':yaml'.
  config.openapi_format = :yaml
end
