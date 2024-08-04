class Category < ApplicationRecord
  has_many :products
  validates :name, presence: true

  # 定义 ransackable_attributes 方法
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "id", "name", "updated_at"]
  end

  # 定义 ransackable_associations 方法
  def self.ransackable_associations(auth_object = nil)
    ["products"]
  end
end
