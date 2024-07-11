class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items
  has_many :reviews
  validates :name, :price, :category, presence: true

  def self.search(query)
    joins(:category).where("products.name LIKE ? OR categories.name LIKE ?", "%#{query}%", "%#{query}%")
  end
end
