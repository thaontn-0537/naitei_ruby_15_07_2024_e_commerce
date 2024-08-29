class SetDefaultSoldToProducts < ActiveRecord::Migration[7.0]
  def change
    change_column_default :products, :sold, 0
  end
end
