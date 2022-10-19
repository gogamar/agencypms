class AddCompanyzipToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :companyzip, :string
  end
end
