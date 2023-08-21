class AddChargeTypeToCharges < ActiveRecord::Migration[7.0]
  def change
    add_column :charges, :charge_type, :string
  end
end
