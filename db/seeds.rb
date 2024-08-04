require 'json'

# Path to your JSON file
json_file_path = Rails.root.join('db', 'cards_data.json')

# Read the JSON file
file = File.read(json_file_path)
data = JSON.parse(file)

# Clear existing data
Product.delete_all
Category.delete_all
Province.delete_all

# Seed provinces data
Province.create!([
  # your provinces data here
])

# Seed products and categories
data.each do |product_data|
  category_record = Category.find_or_create_by!(name: product_data['category'])
  product = Product.new(
    name: product_data['name'],
    price: product_data['price'].tr('$', '').to_f,
    category: category_record
  )

  # Attach the image
  image_path = Rails.root.join('app', 'assets', 'images', product_data['image'])
  if File.exist?(image_path)
    product.image.attach(io: File.open(image_path), filename: File.basename(image_path))
  else
    Rails.logger.warn "Image file not found: #{image_path}"
  end

  product.save!
end

puts "Database seeded successfully with product and province data!"
