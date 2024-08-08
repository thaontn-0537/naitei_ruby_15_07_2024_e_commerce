class CreateOrders < ActiveRecord::Migration[7.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true
      t.integer :total
      t.date :paid_at
      t.text :place
      t.integer :status, default: 0
      t.string :refuse_reason

      t.timestamps
    end
    add_index :orders, :status
  end
end
