class ChangeDiscountPrecisionToFourDecimal < ActiveRecord::Migration[7.0]
  def change
    change_column :earnings, :discount, :decimal, precision: 10, scale: 4
  end
end
