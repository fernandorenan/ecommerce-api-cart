require 'rails_helper'

RSpec.describe "/carts", type: :request do
  describe "POST /add_items" do
    let(:cart) { create(:cart) }
    let(:product) { create(:product, name: "Test Product", price: 10.0) }
    let!(:cart_item) { create(:cart_item, cart: cart, product: product, quantity: 1) }

    context 'when the product already is in the cart' do
      before do
        allow_any_instance_of(CartsController).to receive(:session).and_return({ id: cart.id })
      end

      subject do
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
        post '/cart/add_items', params: { product_id: product.id, quantity: 1 }, as: :json
      end

      it 'updates the quantity of the existing item in the cart' do
        expect { subject }.to change { cart_item.reload.quantity }.by(2)
      end
    end
  end

  describe "POST /cart" do
    let(:product) { create(:product, name: "Test Product", price: 10.0) }

    context "with valid product and quantity" do
      it "creates a new cart and adds product" do
        expect do
          post '/cart', params: { product_id: product.id, quantity: 2 }, as: :json
        end.to change(Cart, :count).by(1)

        expect(response).to have_http_status(:ok)
        json_response = response.parsed_body
        expect(json_response['products'].first).to include(
          'id' => product.id,
          'quantity' => 2
        )
      end
    end

    context "with invalid product" do
      it "returns product not found error" do
        post '/cart', params: { product_id: 999_999, quantity: 1 }, as: :json

        expect(response).to have_http_status(:not_found)
        json_response = response.parsed_body
        expect(json_response).to eq({ 'error' => I18n.t('controllers.carts.errors.product_not_found') })
      end
    end

    context "with invalid quantity" do
      it "returns quantity validation error when quantity is zero" do
        post '/cart', params: { product_id: product.id, quantity: 0 }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response).to eq({ 'error' => I18n.t('controllers.carts.errors.invalid_quantity') })
      end

      it "returns quantity validation error when quantity is negative" do
        post '/cart', params: { product_id: product.id, quantity: -1 }, as: :json

        expect(response).to have_http_status(:unprocessable_entity)
        json_response = response.parsed_body
        expect(json_response).to eq({ 'error' => I18n.t('controllers.carts.errors.invalid_quantity') })
      end
    end

    context "with missing parameters" do
      it "returns error when product_id is missing" do
        post '/cart', params: { quantity: 1 }, as: :json

        expect(response).to have_http_status(:not_found)
        json_response = response.parsed_body
        expect(json_response).to eq({ 'error' => I18n.t('controllers.carts.errors.product_not_found') })
      end
    end
  end

  describe "Response structure" do
    let(:product) { create(:product, name: "Test Product", price: 15.50) }

    context "POST /cart successful response" do
      it "returns correct JSON structure with all required fields" do
        post '/cart', params: { product_id: product.id, quantity: 3 }, as: :json

        expect(response).to have_http_status(:ok)
        expect(response.content_type).to match(a_string_including("application/json"))

        json_response = response.parsed_body
        expect(json_response).to have_key('id')
        expect(json_response).to have_key('products')
        expect(json_response).to have_key('total_price')

        product_data = json_response['products'].first
        expect(product_data).to include(
          'id' => product.id,
          'name' => product.name,
          'quantity' => 3,
          'unit_price' => 15.5,
          'total_price' => 46.5
        )
      end

      it "calculates total price correctly" do
        post '/cart', params: { product_id: product.id, quantity: 4 }, as: :json

        json_response = response.parsed_body
        expect(json_response['total_price']).to eq(62.0) # 15.50 * 4
      end
    end
  end
end
