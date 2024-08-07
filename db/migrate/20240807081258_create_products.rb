class CreateProducts < ActiveRecord::Migration[7.0]
  def change
    create_table :products do |t|
      t.references :category, null: false, foreign_key: true
      t.string :product_name, null: false
      t.string :description
      t.integer :price, null: false
      t.integer :stock
      t.integer :sold
      t.float :rating

      t.timestamps
    end
  end
end
