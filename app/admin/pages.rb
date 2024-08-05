ActiveAdmin.register Page do
    permit_params :title, :content, :page_type
  
    form do |f|
      f.inputs 'Page Details' do
        f.input :title
        f.input :content, as: :text
        f.input :page_type, as: :select, collection: ['contact', 'about'], include_blank: false
      end
      f.actions
    end
  
    show do
      attributes_table do
        row :title
        row :content do |page|
          # Assuming you might store HTML content and want it to render safely in the show page
          page.content.html_safe
        end
        row :page_type
      end
    end
  
    # Using 'page_type' as the id parameter for finding specific pages
    controller do
      defaults finder: :find_by_page_type
  
      private
  
      def find_resource
        scoped_collection.find_by(page_type: params[:id])
      end
    end
  
    # This adjusts the Active Admin index page to correctly handle searches and filters
    filter :title
    filter :content
    filter :page_type, as: :select, collection: -> { Page.distinct.pluck(:page_type) }
  end
  