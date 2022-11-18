class RemoveCompanyTypeFromProfiles < ActiveRecord::Migration[7.0]
  def change
    remove_column :profiles, :companytype
  end
end
