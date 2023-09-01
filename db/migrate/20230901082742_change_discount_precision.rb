class ChangeDiscountPrecision < ActiveRecord::Migration[7.0]
  def change
    change_column :earnings, :discount, :decimal, precision: 5, scale: 2
  end
end
