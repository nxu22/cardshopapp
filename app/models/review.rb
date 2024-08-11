class Review < ApplicationRecord
  belongs_to :product
  belongs_to :user
  belongs_to :order

  def self.ransackable_attributes(auth_object = nil)
    ["comment", "created_at", "id", "order_id", "product_id", "rating", "updated_at", "user_id"]
  end
end
