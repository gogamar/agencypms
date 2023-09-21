class AddColumnsToCompanies < ActiveRecord::Migration[7.0]
  def change
    rename_column :companies, :vat, :vat_number
    rename_column :companies, :address, :street
    rename_column :companies, :phone, :city
    add_column :companies, :post_code, :string
    add_column :companies, :region, :string
    add_column :companies, :country, :string
    add_column :companies, :bank_account, :string
    add_column :companies, :administrator, :string
    add_column :companies, :vat_tax, :float
    add_column :companies, :vat_tax_payer, :boolean
    add_column :companies, :realtor_number, :string
    add_column :companies, :local_realtor_number, :string
  end
end
