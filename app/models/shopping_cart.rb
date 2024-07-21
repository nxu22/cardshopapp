class ShoppingCart < ApplicationRecord
  belongs_to :user
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items

  def add_product(product)
    current_item = cart_items.find_by(product_id: product.id)
    if current_item
      current_item.increment(:quantity)
    else
      current_item = cart_items.build(product: product, quantity: 1)
    end
    current_item.save
  end

  def remove_product(product)
    current_item = cart_items.find_by(product_id: product.id)
    if current_item
      current_item.decrement(:quantity)
      current_item.save
      current_item.destroy if current_item.quantity <= 0
    end
  end

  def total_price
    cart_items.sum { |item| item.product.price * item.quantity }
  end
end
