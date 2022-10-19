class AddOfficezipToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :officezip, :string
  end
end
