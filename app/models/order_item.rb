class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # Define Ransack searchable attributes
  def self.ransackable_attributes(auth_object = nil)
    # List all attributes of OrderItem that can be involved in search
    # Assuming typical attributes such as 'id', 'order_id', 'product_id', 'quantity', 'price'
    # Adjust the list according to your actual attributes
    ["id", "order_id", "product_id", "quantity", "price"]
  end
end
