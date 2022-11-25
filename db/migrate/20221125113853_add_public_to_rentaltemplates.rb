class AddPublicToRentaltemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :rentaltemplates, :public, :boolean, default: false
  end
end
