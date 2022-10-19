class AddOfficeaddressToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :officeaddress, :string
  end
end
