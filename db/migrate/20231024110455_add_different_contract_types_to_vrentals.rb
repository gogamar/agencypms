class AddDifferentContractTypesToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :contract_type, :string, default: "fixed_price"
    add_column :vrentals, :fixed_price_amount, :decimal, precision: 10, scale: 2
    add_column :vrentals, :fixed_price_frequency, :string
  end
end
