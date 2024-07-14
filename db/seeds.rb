require 'json'

# Path to your JSON file
json_file_path = Rails.root.join('db', 'cards_data.json')

# Read the JSON file
file = File.read(json_file_path)
data = JSON.parse(file)

# Clear existing data for provinces only
Province.delete_all

# Seed provinces data
Province.create!([
  { name: 'Alberta', gst: 5.0, pst: 0.0, hst: 0.0, qst: 0.0 },
  { name: 'British Columbia', gst: 5.0, pst: 7.0, hst: 0.0, qst: 0.0 },
  { name: 'Manitoba', gst: 5.0, pst: 7.0, hst: 0.0, qst: 0.0 },
  { name: 'New Brunswick', gst: 0.0, pst: 0.0, hst: 15.0, qst: 0.0 },
  { name: 'Newfoundland and Labrador', gst: 0.0, pst: 0.0, hst: 15.0, qst: 0.0 },
  { name: 'Nova Scotia', gst: 0.0, pst: 0.0, hst: 15.0, qst: 0.0 },
  { name: 'Ontario', gst: 0.0, pst: 0.0, hst: 13.0, qst: 0.0 },
  { name: 'Prince Edward Island', gst: 0.0, pst: 0.0, hst: 15.0, qst: 0.0 },
  { name: 'Quebec', gst: 5.0, pst: 0.0, hst: 0.0, qst: 9.975 },
  { name: 'Saskatchewan', gst: 5.0, pst: 6.0, hst: 0.0, qst: 0.0 }
])


# Ensure existing products and categories are retained
# Iterate over each product in the JSON data
data.each do |product_data|
  # Find or create the category
  category_record = Category.find_or_create_by(name: product_data['category'])

  # Create the product
  Product.find_or_create_by!(
    name: product_data['name'],
    price: product_data['price'].tr('$', '').to_f, # Convert price to float
    category: category_record,
    image: product_data['image']
  )
end

puts "Database seeded successfully with product and province data!"
