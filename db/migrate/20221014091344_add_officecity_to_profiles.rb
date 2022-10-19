class AddOfficecityToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :officecity, :string
  end
end
