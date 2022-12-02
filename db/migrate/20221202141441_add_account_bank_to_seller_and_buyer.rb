class AddAccountBankToSellerAndBuyer < ActiveRecord::Migration[7.0]
  def change
    add_column :sellers, :account_bank, :string
    add_column :buyers, :account_bank, :string
  end
end
