require 'rails_helper'

RSpec.describe MarkCartAsAbandonedJob, type: :job do
  describe '#perform' do
    let!(:active_cart_to_abandon) { create(:cart, :active_cart_to_abandon) }
    let!(:abandoned_cart_to_remove) { create(:cart, :abandoned_cart_to_destroy) }
    let!(:recent_active_cart) { create(:cart, status: :active, last_interaction_at: 1.hour.ago) }
    let!(:recent_abandoned_cart) { create(:cart, status: :abandoned, last_interaction_at: 2.days.ago) }

    it 'marks old active carts as abandoned and removes old abandoned carts' do
      expect { described_class.new.perform }
        .to change { active_cart_to_abandon.reload.status }.from('active').to('abandoned')
        .and change { Cart.exists?(abandoned_cart_to_remove.id) }.from(true).to(false)

      expect(recent_active_cart.reload.status).to eq('active')
      expect(Cart.exists?(recent_abandoned_cart.id)).to be true
    end
  end

  describe 'private methods' do
    let(:job) { described_class.new }

    describe '#mark_inactive_carts_as_abandoned' do
      let!(:old_active_cart) { create(:cart, status: :active, last_interaction_at: 4.hours.ago) }
      let!(:recent_active_cart) { create(:cart, status: :active, last_interaction_at: 1.hour.ago) }

      it 'marks only active carts older than 3 hours as abandoned' do
        expect { job.send(:mark_inactive_carts_as_abandoned) }
          .to change { old_active_cart.reload.status }.from('active').to('abandoned')

        expect(recent_active_cart.reload.status).to eq('active')
      end
    end

    describe '#remove_old_abandoned_carts' do
      let!(:old_abandoned_cart) { create(:cart, status: :abandoned, last_interaction_at: 8.days.ago) }
      let!(:recent_abandoned_cart) { create(:cart, status: :abandoned, last_interaction_at: 2.days.ago) }

      it 'removes only abandoned carts older than 7 days' do
        expect { job.send(:remove_old_abandoned_carts) }
          .to change { Cart.exists?(old_abandoned_cart.id) }.from(true).to(false)

        expect(Cart.exists?(recent_abandoned_cart.id)).to be true
      end
    end
  end
end
