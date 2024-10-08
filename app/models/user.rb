class User < ApplicationRecord
  belongs_to :province
  has_many :orders
  has_many :reviews
  has_one :shopping_cart

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :username, presence: true, uniqueness: true
  validates :email, presence: true, uniqueness: true

  # Define which attributes are searchable with Ransack
  def self.ransackable_attributes(auth_object = nil)
    %w[address admin created_at email id id_value province_id role updated_at username]
  end

  def admin?
    role == "admin"
  end
end