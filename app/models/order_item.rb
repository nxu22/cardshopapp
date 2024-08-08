class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  # Ensure these columns exist in your database
  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price, numericality: { greater_than_or_equal_to: 0 }

  # Define Ransack searchable attributes
  def self.ransackable_attributes(auth_object = nil)
    # List all attributes of OrderItem that can be involved in search
    # Assuming typical attributes such as 'id', 'order_id', 'product_id', 'quantity', 'price'
    # Adjust the list according to your actual attributes
    %w[id order_id product_id quantity price]
  end

  # Calculate the total price for this order item
  def total_price
    quantity * (price || product.price)
  end
end
