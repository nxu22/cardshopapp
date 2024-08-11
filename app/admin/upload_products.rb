ActiveAdmin.register_page "Upload Products" do
    content do
      render partial: 'admin/upload_products'
    end
  
    page_action :import, method: :post do
      require 'json'
  
      json_file = params[:file]
      json_data = JSON.parse(File.read(json_file.path))
  
      json_data.each do |product|
        Product.create!(
          name: product['name'],
          image: product['image'],
          price: product['price'],
          category: product['category']
        )
      end
  
      redirect_to admin_products_path, notice: "Products imported successfully!"
    end
  end
  