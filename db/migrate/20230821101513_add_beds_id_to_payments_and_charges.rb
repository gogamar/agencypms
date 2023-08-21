class AddBedsIdToPaymentsAndCharges < ActiveRecord::Migration[7.0]
  def change
    add_column :payments, :beds_id, :string
    add_column :charges, :beds_id, :string
  end
end
