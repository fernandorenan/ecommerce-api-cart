require 'rails_helper'

RSpec.describe Cart, type: :model do
  context 'when validating' do
    it 'validates numericality of total_price' do
      cart = described_class.new(total_price: -1)
      expect(cart.valid?).to be_falsey
      expect(cart.errors[:total_price]).to include("deve ser maior ou igual a 0")
    end
  end

  describe 'mark_as_abandoned' do
    let(:shopping_cart) { create(:cart) }

    it 'marks the shopping cart as abandoned if inactive for a certain time' do
      shopping_cart.update(last_interaction_at: 3.hours.ago)
      expect { shopping_cart.mark_as_abandoned }.to change { shopping_cart.abandoned? }.from(false).to(true)
    end
  end

  describe 'remove_if_abandoned' do
    let(:shopping_cart) { create(:cart, last_interaction_at: 7.days.ago) }

    it 'removes the shopping cart if abandoned for a certain time' do
      shopping_cart.mark_as_abandoned
      expect { shopping_cart.remove_if_abandoned }.to change { Cart.count }.by(-1)
    end
  end

  describe 'touch_activity!' do
    let(:cart) { create(:cart, status: 'abandoned') }

    it 'updates last_interaction_at and sets status to active' do
      cart.touch_activity!
      expect(cart.last_interaction_at).to be_within(1.second).of(Time.current)
      expect(cart.status).to eq('active')
    end
  end

  describe 'update_total_price!' do
    let(:cart) { create(:cart) }
    let(:product1) { create(:product, price: 10.0) }
    let(:product2) { create(:product, price: 20.0) }

    it 'updates total_price based on cart items quantities and unit prices' do
      cart.cart_items.create!(product: product1, quantity: 2, unit_price: 10.0)
      cart.cart_items.create!(product: product2, quantity: 1, unit_price: 20.0)

      cart.update_total_price!

      expect(cart.total_price).to eq(40.0)
    end
  end
end
