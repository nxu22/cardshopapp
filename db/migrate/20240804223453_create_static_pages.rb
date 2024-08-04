class CreateStaticPages < ActiveRecord::Migration[7.1]
  def change
    create_table :static_pages do |t|
      t.string :title
      t.text :content

      t.timestamps
    end
  end
end
