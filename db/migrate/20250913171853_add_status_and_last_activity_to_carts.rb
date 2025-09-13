class AddStatusAndLastActivityToCarts < ActiveRecord::Migration[7.1]
  def change
    add_column :carts, :status, :string, default: 'active', null: false
    add_column :carts, :last_activity_at, :datetime
  end
end
