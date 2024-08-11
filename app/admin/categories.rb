# app/admin/categories.rb
ActiveAdmin.register Category do
    permit_params :name
  
    index do
      selectable_column
      id_column
      column :name
      actions
    end
  
    form do |f|
      f.inputs 'Category Details' do
        f.input :name
      end
      f.actions
    end
  
    show do
      attributes_table do
        row :name
        row :created_at
        row :updated_at
      end
  
      panel "Products" do
        table_for category.products do
          column :name
          column :price
          column :description
          column :image do |product|
            image_tag url_for(product.image) if product.image.attached?
          end
          column :created_at
          column :updated_at
          # Replace `actions` with action links
          column "Actions" do |product|
            link_to "View", admin_product_path(product)
          end
        end
      end
    end
  end
  