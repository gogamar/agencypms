class AddRegistryCodeToRealestates < ActiveRecord::Migration[7.0]
  def change
    add_column :realestates, :registry_code, :string
  end
end
