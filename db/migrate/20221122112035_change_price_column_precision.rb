class ChangePriceColumnPrecision < ActiveRecord::Migration[7.0]
  def change
    change_column :contracts, :price, :float, precision: 2, scale: 2
    change_column :contracts, :down_payment, :float, precision: 2, scale: 2
  end
end
