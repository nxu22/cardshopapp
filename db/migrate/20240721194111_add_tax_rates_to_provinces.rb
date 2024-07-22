class AddTaxRatesToProvinces < ActiveRecord::Migration[7.1]
  def change
    add_column :provinces, :pst_rate, :decimal
    add_column :provinces, :gst_rate, :decimal
    add_column :provinces, :hst_rate, :decimal
    add_column :provinces, :qst_rate, :decimal
  end
end
