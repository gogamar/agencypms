class AddDeedDetailsToRealestates < ActiveRecord::Migration[7.0]
  def change
    add_column :realestates, :protocol, :string
    add_column :realestates, :deed_date, :date
    add_column :realestates, :notary, :string
    add_column :realestates, :notary_fullname, :string
    add_column :realestates, :mortgage_bank, :string
    add_column :realestates, :mortgage_amount, :float
  end
end
