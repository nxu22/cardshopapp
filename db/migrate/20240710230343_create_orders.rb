class CreateOrders < ActiveRecord::Migration[7.1]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.string :status
      t.decimal :total_price
      t.decimal :PST
      t.decimal :GST
      t.decimal :HST

      t.timestamps
    end
  end
end
