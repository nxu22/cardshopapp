class AddPaymentIdToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :payment_id, :string
  end
end
