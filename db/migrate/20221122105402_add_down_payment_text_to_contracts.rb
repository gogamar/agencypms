class AddDownPaymentTextToContracts < ActiveRecord::Migration[7.0]
  def change
    add_column :contracts, :down_payment_text, :string
  end
end
