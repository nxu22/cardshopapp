class User < ApplicationRecord
  belongs_to :province
  has_many :orders
  has_many :reviews
  has_one :shopping_cart

  has_secure_password
  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  def admin?
    role == "admin"
  end
end
