class AddQstToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :qst, :decimal
  end
end
