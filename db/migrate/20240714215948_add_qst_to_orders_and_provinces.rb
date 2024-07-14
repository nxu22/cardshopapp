class AddQstToOrdersAndProvinces < ActiveRecord::Migration[6.1]
  def change
    add_column :orders, :qst, :decimal, precision: 10, scale: 2
    add_column :provinces, :qst, :decimal, precision: 10, scale: 2
  end
end
