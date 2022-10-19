class AddOfficephoneToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :officephone, :string
  end
end
