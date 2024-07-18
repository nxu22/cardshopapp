class Order < ApplicationRecord
  belongs_to :user
  has_many :order_items
  has_many :reviews
   # Add these lines if not already present
   validates :payment_id, presence: true
   validates :status, presence: true
 
end

