class Cart < ApplicationRecord
  validates :total_price, numericality: { greater_than_or_equal_to: 0 }
  has_many :cart_items, dependent: :destroy

  enum :status, { active: 'active', abandoned: 'abandoned', completed: 'completed' }

  def update_total_price!
    update(total_price: cart_items.sum('quantity * unit_price'))
  end

  def mark_as_abandoned
    update!(status: :abandoned)
  end

  def remove_if_abandoned
    destroy if abandoned?
  end

  def abandoned?
    status == 'abandoned'
  end
 
  def touch_activity!
    update(last_interaction_at: Time.current, status: :active)
  end
end
