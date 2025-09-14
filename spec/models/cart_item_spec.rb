require 'rails_helper'

RSpec.describe CartItem, type: :model do
  let(:cart) { create(:cart) }
  let(:product) { create(:product, price: 20.0) }

  it 'updates cart activity after save' do
    cart.cart_items.create!(product: product, quantity: 2, unit_price: product.price)

    expect(cart.reload.total_price).to eq(40.0)
    expect(cart.last_interaction_at).to be_within(1.second).of(Time.current)
  end

  it 'updates cart activity after destroy' do
    item = cart.cart_items.create!(product: product, quantity: 2, unit_price: product.price)

    expect { item.destroy }.to change { cart.reload.total_price }.to(0)
  end

  it 'calculates total_price' do
    item = cart.cart_items.create!(product: product, quantity: 3, unit_price: product.price)

    expect(item.total_price).to eq(60.0)
  end

  describe '#update_cart_activity' do
    let(:cart) { create(:cart) }
    let(:item) { build(:cart_item, cart: cart) }

    it 'calls touch_activity! and update_total_price! on cart' do
      expect(cart).to receive(:touch_activity!)
      expect(cart).to receive(:update_total_price!)

      item.save!
    end
  end
end
