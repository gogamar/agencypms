class AddCompanyphoneToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :companyphone, :string
  end
end
