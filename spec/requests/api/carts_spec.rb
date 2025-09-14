require 'swagger_helper'

RSpec.describe 'Carts API', type: :request do
  path '/cart' do
    get 'Visualiza o carrinho atual' do
      tags 'Carrinho'
      description 'Retorna o conteúdo do carrinho da sessão atual'
      produces 'application/json'

      response 200, 'Carrinho encontrado' do
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 products: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 1 },
                       name: { type: :string, example: 'Produto Exemplo' },
                       quantity: { type: :integer, example: 2 },
                       unit_price: { type: :number, format: :float, example: 29.99 },
                       total_price: { type: :number, format: :float, example: 59.98 }
                     }
                   }
                 },
                 total_price: { type: :number, format: :float, example: 59.98 }
               }

        let!(:cart) { create(:cart) }
        let!(:product) { create(:product, name: 'Produto Exemplo', price: 29.99) }
        let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 2) }

        before do
          allow_any_instance_of(CartsController).to receive(:session).and_return({ id: cart.id })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['products']).to be_an(Array)
          expect(data['products'].first['name']).to eq('Produto Exemplo')
        end
      end

      response 200, 'Carrinho vazio' do
        schema type: :object,
               properties: {
                 message: { type: :string, example: 'Carrinho vazio' }
               }

        let!(:cart) { create(:cart) }

        before do
          allow_any_instance_of(CartsController).to receive(:session).and_return({ id: cart.id })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['message']).to eq('Carrinho vazio')
        end
      end

      response 404, 'Carrinho não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Carrinho não encontrado' }
               }

        before do
          allow_any_instance_of(CartsController).to receive(:session).and_return({ id: nil })
        end

        run_test!
      end
    end

    post 'Cria um carrinho e adiciona produto' do
      tags 'Carrinho'
      description 'Cria um novo carrinho ou usa o existente e adiciona um produto'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :cart_params, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :integer, example: 1, description: 'ID do produto a ser adicionado' },
          quantity: { type: :integer, example: 2, description: 'Quantidade do produto' }
        },
        required: ['product_id', 'quantity']
      }

      response 200, 'Produto adicionado ao carrinho' do
        schema type: :object,
               properties: {
                 id: { type: :integer, example: 1 },
                 products: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer, example: 1 },
                       name: { type: :string, example: 'Smartphone XYZ' },
                       quantity: { type: :integer, example: 2 },
                       unit_price: { type: :number, format: :float, example: 899.99 },
                       total_price: { type: :number, format: :float, example: 1799.98 }
                     }
                   }
                 },
                 total_price: { type: :number, format: :float, example: 1799.98 }
               }

        let!(:product) { create(:product, name: 'Smartphone XYZ', price: 899.99) }
        let(:cart_params) { { product_id: product.id, quantity: 2 } }

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['products'].first['name']).to eq('Smartphone XYZ')
          expect(data['products'].first['quantity']).to eq(2)
        end
      end

      response 404, 'Produto não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'O produto não foi encontrado' }
               }

        let(:cart_params) { { product_id: 999999, quantity: 1 } }
        run_test!
      end

      response 422, 'Quantidade inválida' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'A quantidade deve ser maior que zero' }
               }

        let!(:product) { create(:product) }
        let(:cart_params) { { product_id: product.id, quantity: 0 } }
        run_test!
      end
    end
  end

  path '/cart/add_items' do
    post 'Adiciona itens ao carrinho existente' do
      tags 'Carrinho'
      description 'Adiciona mais itens de um produto ao carrinho existente'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :add_item_params, in: :body, schema: {
        type: :object,
        properties: {
          product_id: { type: :integer, example: 1, description: 'ID do produto' },
          quantity: { type: :integer, example: 3, description: 'Quantidade a adicionar' }
        },
        required: ['product_id', 'quantity']
      }

      response 200, 'Itens adicionados com sucesso' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 products: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       quantity: { type: :integer },
                       unit_price: { type: :number, format: :float },
                       total_price: { type: :number, format: :float }
                     }
                   }
                 },
                 total_price: { type: :number, format: :float }
               }

        let!(:cart) { create(:cart) }
        let!(:product) { create(:product, name: 'Notebook ABC', price: 1299.99) }
        let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }
        let(:add_item_params) { { product_id: product.id, quantity: 2 } }

        before do
          allow_any_instance_of(CartsController).to receive(:session).and_return({ id: cart.id })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data['products'].first['quantity']).to eq(3)  # 1 + 2
        end
      end

      response 404, 'Carrinho não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Carrinho não encontrado' }
               }

        let!(:product) { create(:product) }
        let(:add_item_params) { { product_id: product.id, quantity: 1 } }

        before do
          allow_any_instance_of(CartsController).to receive(:session).and_return({ id: nil })
        end

        run_test!
      end

      response 404, 'Produto não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'O produto não foi encontrado' }
               }

        let!(:cart) { create(:cart) }
        let(:add_item_params) { { product_id: 999999, quantity: 1 } }

        before do
          allow_any_instance_of(CartsController).to receive(:session).and_return({ id: cart.id })
        end

        run_test!
      end
    end
  end

  path '/cart/{product_id}' do
    parameter name: :product_id, in: :path, type: :integer, description: 'ID do produto a ser removido'

    delete 'Remove produto do carrinho' do
      tags 'Carrinho'
      description 'Remove completamente um produto do carrinho'
      produces 'application/json'

      response 200, 'Produto removido com sucesso' do
        schema type: :object,
               properties: {
                 id: { type: :integer },
                 products: {
                   type: :array,
                   items: {
                     type: :object,
                     properties: {
                       id: { type: :integer },
                       name: { type: :string },
                       quantity: { type: :integer },
                       unit_price: { type: :number, format: :float },
                       total_price: { type: :number, format: :float }
                     }
                   }
                 },
                 total_price: { type: :number, format: :float }
               }

        let!(:cart) { create(:cart) }
        let!(:product1) { create(:product, name: 'Produto 1', price: 100.0) }
        let!(:product2) { create(:product, name: 'Produto 2', price: 200.0) }
        let!(:cart_item1) { create(:cart_item, cart: cart, product: product1, quantity: 1) }
        let!(:cart_item2) { create(:cart_item, cart: cart, product: product2, quantity: 2) }
        let(:product_id) { product1.id }

        before do
          allow_any_instance_of(CartsController).to receive(:session).and_return({ id: cart.id })
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          product_ids = data['products'].map { |p| p['id'] }
          expect(product_ids).not_to include(product1.id)
          expect(product_ids).to include(product2.id)
        end
      end

      response 404, 'Carrinho não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Carrinho não encontrado' }
               }

        let(:product_id) { 1 }

        before do
          allow_any_instance_of(CartsController).to receive(:session).and_return({ id: nil })
        end

        run_test!
      end

      response 404, 'Produto não encontrado' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'O produto não foi encontrado' }
               }

        let!(:cart) { create(:cart) }
        let(:product_id) { 999999 }

        before do
          allow_any_instance_of(CartsController).to receive(:session).and_return({ id: cart.id })
        end

        run_test!
      end

      response 404, 'Item não encontrado no carrinho' do
        schema type: :object,
               properties: {
                 error: { type: :string, example: 'Item não encontrado no carrinho' }
               }

        let!(:cart) { create(:cart) }
        let!(:product) { create(:product) }
        let(:product_id) { product.id }

        before do
          allow_any_instance_of(CartsController).to receive(:session).and_return({ id: cart.id })
        end

        run_test!
      end
    end
  end
end
