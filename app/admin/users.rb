ActiveAdmin.register User do
    # Permit parameters, adjust according to your application needs
    permit_params :email, :username, :admin, :password, :password_confirmation
  
    index do
      selectable_column
      id_column
      column :email
      column :username
      column :admin
      actions
    end
  
    show do
      attributes_table do
        row :email
        row :username
        row :admin
      end
  
      panel "Orders" do
        table_for user.orders do
          column :id
          column :created_at
          column :status
          column :total_price
          column "Items" do |order|
            order.order_items.map { |oi| "#{oi.product.name} (#{oi.quantity})" }.join(", ")
          end
          column "Taxes" do |order|
            # Ensure you calculate taxes in your Order model
            number_to_currency(order.total_price * 0.1)  # Example tax rate of 10%
          end
          column "Grand Total" do |order|
            number_to_currency(order.total_price + (order.total_price * 0.1))
          end
          column "" do |order|
            links = ''.html_safe
            links += link_to 'View', admin_order_path(order), class: "member_link"
            links
          end
        end
      end
    end
  
    filter :email
    filter :username
  end
  