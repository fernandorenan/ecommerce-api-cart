class Cart < ApplicationRecord
  validates_numericality_of :total_price, greater_than_or_equal_to: 0
  has_many :cart_items, dependent: :destroy
  # TODO: lógica para marcar o carrinho como abandonado e remover se abandonado

  def update_total_price!
    update(total_price: cart_items.sum('quantity * unit_price'))
  end
end
