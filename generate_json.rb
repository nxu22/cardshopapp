require 'json'

# Define the image directories with spaces properly escaped
image_directories = {
  'birthday_card' => 'app/assets/images/birthday card',
  'christmas_card' => 'app/assets/images/christmas card',
  'thanksgiving_card' => 'app/assets/images/thanksgiving',
  'valentine_card' => 'app/assets/images/valentine card'
}

# Check if the directory exists
def directory_exists?(path)
  Dir.exist?(path)
end

# Fetch and sort image data
def fetch_image_data(path, card_type)
  if directory_exists?(path)
    puts "Reading images from: #{path}" # Debugging line
    images = Dir.glob("#{path}/*").sort_by { |file| File.basename(file, ".*").to_i }
    puts "Found images: #{images}" # Debugging line
    images.each_with_index.map do |image_path, index|
      {
        id: index + 1,
        name: "#{card_type.capitalize.gsub('_', ' ')} #{index + 1}",
        image: image_path.sub('app/assets/images/', ''), # Make path relative to assets/images
        price: "$5.00",
        category: card_type.capitalize.gsub('_', ' ')
      }
    end
  else
    puts "Directory not found: #{path}" # Debugging line
    []
  end
end

# Generate the data for all categories
data = image_directories.each_with_object([]) do |(category, path), result|
  result.concat(fetch_image_data(path, category))
end

puts "Generated data: #{data}" # Debugging line

# Write to a JSON file
File.open('cards_data.json', 'w') do |f|
  f.write(JSON.pretty_generate(data))
end

puts "JSON file created successfully!"
