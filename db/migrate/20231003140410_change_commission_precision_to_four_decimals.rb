class ChangeCommissionPrecisionToFourDecimals < ActiveRecord::Migration[7.0]
  def change
    change_column :vrentals, :commission, :decimal, precision: 10, scale: 4
  end
end
