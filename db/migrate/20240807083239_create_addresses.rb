class CreateAddresses < ActiveRecord::Migration[7.0]
  def change
    create_table :addresses do |t|
      t.references :user, null: false, foreign_key: true
      t.string :place
      t.boolean :default

      t.timestamps
    end
    add_index :addresses, [:user_id, :place], unique: true
  end
end
