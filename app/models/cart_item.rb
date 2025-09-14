class CartItem < ApplicationRecord
  belongs_to :cart
  belongs_to :product

  after_save :update_cart_activity
  after_destroy :update_cart_activity

  def update_cart_activity
    cart.touch_activity! if cart.present?
    cart.update_total_price! if cart.present?
  end

  def total_price
    quantity * product.price
  end
end
