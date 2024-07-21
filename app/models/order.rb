class Order < ApplicationRecord
  belongs_to :user
  belongs_to :province, optional: true # 如果 province 也可以为空
  has_many :order_items
  has_many :reviews
  
  validates :first_name, :last_name, :email, :address, :province_id, presence: true
  validates :payment_id, :status, presence: true, if: :require_payment_and_status?

  def require_payment_and_status?
    # 只有在需要时才进行 payment_id 和 status 的验证
    false
  end
end
