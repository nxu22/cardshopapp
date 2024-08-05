ActiveAdmin.register ContactPage do
  permit_params :content

  index do
    selectable_column
    id_column
    column :content
    column :created_at
    column :updated_at
    actions
  end

  filter :content
  filter :created_at
  filter :updated_at

  form do |f|
    f.inputs do
      f.input :content
    end
    f.actions
  end
end