class AddUserNameAndUserPhoneToOrders < ActiveRecord::Migration[7.0]
  def change
    add_column :orders, :user_name, :string
    add_column :orders, :user_phone, :string
  end
end
