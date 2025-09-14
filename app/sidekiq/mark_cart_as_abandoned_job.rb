class MarkCartAsAbandonedJob
  include Sidekiq::Job

  queue_as :default

  def perform(*args)
    # TODO Impletemente um Job para gerenciar, marcar como abandonado. E remover carrinhos sem interação.

    carts = Cart.where(last_activity_at: ..3.hours.ago).where(status: 'active')
    carts.each do |cart|
      cart.mark_as_abandoned!
      Rails.logger.debug { "Cart #{cart.id} marked as abandoned." }
    end 

    # Remover carrinhos abandonados após 1 hora
    abandoned_carts = Cart.where(last_activity_at: ..7.days.ago).where(status: 'abandoned')
    abandoned_carts.each do |cart|
      cart.destroy
      Rails.logger.debug { "Abandoned cart #{cart.id} removed." }
    end
  end
end
