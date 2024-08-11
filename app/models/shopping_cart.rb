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
    
    unless current_item.save
      Rails.logger.error "Failed to save cart item: #{current_item.errors.full_messages.join(', ')}"
    end
  end

  def remove_product(product)
    current_item = cart_items.find_by(product_id: product.id)
    if current_item
      current_item.decrement(:quantity)
      current_item.save
      current_item.destroy if current_item.quantity <= 0
    end
  end

  def total_price_with_taxes
    return 0 unless user.province # Ensure province is set
  
    subtotal = cart_items.sum { |item| item.product.price * item.quantity }
    pst = gst = hst = qst = 0
  
    pst_rate = user.province.pst || 0.0
    gst_rate = user.province.gst || 0.0
    hst_rate = user.province.hst || 0.0
    qst_rate = user.province.qst || 0.0
  
    cart_items.each do |item|
      price = item.product.price * item.quantity
      pst += price * (pst_rate / 100)
      gst += price * (gst_rate / 100)
      hst += price * (hst_rate / 100)
      qst += price * (qst_rate / 100)
    end
  
    subtotal + pst + gst + hst + qst
  end
  
end
