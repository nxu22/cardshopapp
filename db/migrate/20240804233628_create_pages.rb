class CreatePages < ActiveRecord::Migration[7.1]
  def change
    create_table :pages do |t|
      t.string :title
      t.text :content
      t.string :page_type

      t.timestamps
    end
  end
end
