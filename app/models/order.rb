class Order < ApplicationRecord
  belongs_to :user
  belongs_to :province, optional: true
  has_many :order_items
  has_many :reviews

  validates :first_name, :last_name, :email, :address, :province_id, presence: true
  validates :payment_id, :status, presence: true, if: :payment_processed?

  def payment_processed?
    status == 'completed'
  end
end
