class RevertChangeDiscountPrecision < ActiveRecord::Migration[7.0]
  def up
    change_column :earnings, :discount, :decimal, precision: 10, scale: 2
  end

  def down
    change_column :earnings, :discount, :decimal, precision: 5, scale: 2
  end
end
