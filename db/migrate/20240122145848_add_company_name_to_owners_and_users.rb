class AddCompanyNameToOwnersAndUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :owners, :title, :string
    add_column :owners, :firstname, :string
    add_column :owners, :lastname, :string
    rename_column :owners, :fullname, :company_name
    add_column :users, :title, :string
    add_column :users, :company_name, :string
  end
end
