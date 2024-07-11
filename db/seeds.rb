require 'json'

# Path to your JSON file
json_file_path = Rails.root.join('db', 'cards_data.json')

# Read the JSON file
file = File.read(json_file_path)
data = JSON.parse(file)

# Clear existing data
Product.delete_all
Category.delete_all

# Iterate over each product in the JSON data
data.each do |product_data|
  # Find or create the category
  category_record = Category.find_or_create_by(name: product_data['category'])

  # Create the product
  Product.create!(
    name: product_data['name'],
    price: product_data['price'].tr('$', '').to_f, # Convert price to float
    category: category_record,
    image: product_data['image']
  )
end

puts "Database seeded successfully with product data!"
