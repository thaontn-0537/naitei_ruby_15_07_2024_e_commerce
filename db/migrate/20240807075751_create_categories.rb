class CreateCategories < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.references :parent, null: true, foreign_key: {to_table: :categories}
      t.string :parent_path
      t.string :category_name, null: false

      t.timestamps
    end
  end
end
