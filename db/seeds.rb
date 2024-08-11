# db/seeds.rb

require 'json'

# Path to your JSON file
json_file_path = Rails.root.join('db', 'cards_data.json')

# Read the JSON file
file = File.read(json_file_path)
data = JSON.parse(file)

# Clear existing data
OrderItem.delete_all
Order.delete_all
Product.delete_all
Category.delete_all
Province.delete_all
StaticPage.delete_all

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

# Seed static pages data
StaticPage.find_or_create_by(title: 'About') do |page|
  page.content = 'Initial content for the about page.'
end

StaticPage.find_or_create_by(title: 'Contact') do |page|
  page.content = 'Initial content for the contact page.'
end

puts "Database seeded successfully with product, province, and static page data!"
