class MarkCartAsAbandonedJob
  include Sidekiq::Job

  queue_as :default

  def perform(*args)
    mark_inactive_carts_as_abandoned
    remove_old_abandoned_carts
  end

  private

  def mark_inactive_carts_as_abandoned
    carts = Cart.where(last_interaction_at: ..3.hours.ago).where(status: 'active')
    carts.each do |cart|
      cart.mark_as_abandoned
      Rails.logger.debug { "Cart #{cart.id} marked as abandoned." }
    end
  end

  def remove_old_abandoned_carts
    abandoned_carts = Cart.where(last_interaction_at: ..7.days.ago).where(status: 'abandoned')
    abandoned_carts.each do |cart|
      cart.remove_if_abandoned
      Rails.logger.debug { "Abandoned cart #{cart.id} removed." }
    end
  end
end
