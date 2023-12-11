class AddActiveToCompanies < ActiveRecord::Migration[7.0]
  def change
    add_column :companies, :active, :boolean, default: false
    add_index :companies, :active, unique: true, where: "active = true"
  end
end
