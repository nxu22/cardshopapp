class Product < ApplicationRecord
  belongs_to :category
  has_many :order_items
  has_many :reviews
  has_one_attached :image

  validates :name, :price, :category, presence: true
  validates :price, presence: true, numericality: { greater_than: 0 }

  # Existing search method for custom queries
  def self.search(query)
    joins(:category).where("products.name LIKE ? OR categories.name LIKE ?", "%#{query}%", "%#{query}%")
  end

  # Ransack searchable attributes
  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "id", "id_value", "image", "name", "on_sale", "price", "updated_at"]
  end

  # Newly added Ransack searchable associations
  def self.ransackable_associations(auth_object = nil)
    ['category', 'order_items', 'reviews']
  end
end
