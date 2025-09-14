require 'swagger_helper'

RSpec.describe 'Products API', type: :request do
  path '/products' do
    get 'Lista todos os produtos' do
      tags 'Produtos'
      description 'Retorna a lista de todos os produtos disponíveis'
      produces 'application/json'

      response 200, 'Produtos listados com sucesso' do
        schema type: :array,
               items: {
                 type: :object,
                 properties: {
                   id: { type: :integer, example: 1 },
                   name: { type: :string, example: 'Produto Exemplo' },
                   price: { type: :number, format: :float, example: 29.99 },
                   created_at: { type: :string, format: :datetime, example: '2024-01-01T10:00:00Z' },
                   updated_at: { type: :string, format: :datetime, example: '2024-01-01T10:00:00Z' }
                 }
               }

        let!(:product) { create(:product, name: 'Produto Exemplo', price: 29.99) }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_an(Array)
          expect(data.first['name']).to eq('Produto Exemplo')
        end
      end
    end

    post 'Cria um novo produto' do
      tags 'Produtos'
      description 'Cria um novo produto com nome e preço'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Smartphone XYZ' },
              price: { type: :number, format: :float, example: 899.99 }
            },
            required: ['name', 'price']
          }
        }
      }

      response 201, 'Produto criado com sucesso' do
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 name: { type: :string, example: 'Smartphone XYZ' },
                 price: { type: :number, format: :float, example: 899.99 },
                 created_at: { type: :string, format: :datetime },
                 updated_at: { type: :string, format: :datetime }
               }

        let(:product) { { product: { name: 'Smartphone XYZ', price: 899.99 } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Smartphone XYZ')
          expect(data['price']).to eq(899.99)
        end
      end

      response 422, 'Dados inválidos' do
        schema type: :object,
               properties: {
                 name: { type: :array, items: { type: :string }, example: ["can't be blank"] },
                 price: { type: :array, items: { type: :string }, example: ["must be greater than 0"] }
               }

        let(:product) { { product: { name: '', price: -1 } } }

        run_test!
      end
    end
  end

  path '/products/{id}' do
    parameter name: :id, in: :path, type: :integer, description: 'ID do produto'

    get 'Mostra um produto específico' do
      tags 'Produtos'
      description 'Retorna os detalhes de um produto específico'
      produces 'application/json'

      response 200, 'Produto encontrado' do
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 name: { type: :string, example: 'Notebook ABC' },
                 price: { type: :number, format: :float, example: 1299.99 },
                 created_at: { type: :string, format: :datetime },
                 updated_at: { type: :string, format: :datetime }
               }

        let!(:product_record) { create(:product, name: 'Notebook ABC', price: 1299.99) }
        let(:id) { product_record.id }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Notebook ABC')
        end
      end

      response 404, 'Produto não encontrado' do
        let(:id) { 999999 }
        run_test!
      end
    end

    put 'Atualiza um produto' do
      tags 'Produtos'
      description 'Atualiza as informações de um produto existente'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :product, in: :body, schema: {
        type: :object,
        properties: {
          product: {
            type: :object,
            properties: {
              name: { type: :string, example: 'Tablet Premium' },
              price: { type: :number, format: :float, example: 599.99 }
            }
          }
        }
      }

      response 200, 'Produto atualizado com sucesso' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 name: { type: :string, example: 'Tablet Premium' },
                 price: { type: :number, format: :float, example: 599.99 },
                 created_at: { type: :string, format: :datetime },
                 updated_at: { type: :string, format: :datetime }
               }

        let!(:product_record) { create(:product, name: 'Tablet Antigo', price: 399.99) }
        let(:id) { product_record.id }
        let(:product) { { product: { name: 'Tablet Premium', price: 599.99 } } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['name']).to eq('Tablet Premium')
          expect(data['price']).to eq(599.99)
        end
      end

      response 422, 'Dados inválidos' do
        let!(:product_record) { create(:product) }
        let(:id) { product_record.id }
        let(:product) { { product: { price: -1 } } }
        run_test!
      end

      response 404, 'Produto não encontrado' do
        let(:id) { 999999 }
        let(:product) { { product: { name: 'Test' } } }
        run_test!
      end
    end

    delete 'Remove um produto' do
      tags 'Produtos'
      description 'Remove um produto do sistema'

      response 204, 'Produto removido com sucesso' do
        let!(:product_record) { create(:product) }
        let(:id) { product_record.id }
        run_test!
      end

      response 404, 'Produto não encontrado' do
        let(:id) { 999999 }
        run_test!
      end
    end
  end
end
