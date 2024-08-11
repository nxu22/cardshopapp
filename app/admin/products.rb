# app/admin/products.rb
ActiveAdmin.register Product do
  permit_params :name, :price, :category_id, :image

  # Define explicit filters to avoid issues
  filter :name
  filter :price
  filter :category

  index do
    selectable_column
    id_column
    column :name
    column :price
    column :category
    column :image do |product|
      image_tag url_for(product.image) if product.image.attached?
    end
    actions
  end

  form do |f|
    f.inputs 'Product Details' do
      f.input :name
      f.input :price
      f.input :category
      f.input :image, as: :file
    end
    f.actions
  end

  show do
    attributes_table do
      row :name
      row :price
      row :category
      row :image do |product|
        image_tag url_for(product.image) if product.image.attached?
      end
    end
  end
end
