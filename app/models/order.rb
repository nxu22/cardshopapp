class Order < ApplicationRecord
  belongs_to :user
  belongs_to :province, optional: true
  has_many :order_items
  has_many :reviews

  validates :first_name, :last_name, :email, :address, :province_id, presence: true
  validates :payment_id, :status, presence: true, if: :require_payment_and_status?

  before_save :set_total_price  # Ensure total_price is set before saving

  def require_payment_and_status?
    # Only validate payment_id and status when required
    false
  end

  private

  def set_total_price
    # Calculate total price from order items, assuming each item responds to `price` and `quantity`
    total = order_items.reduce(0) do |sum, item|
      sum + item.quantity * item.product.price
    end
    self.total_price = total
  end
end
