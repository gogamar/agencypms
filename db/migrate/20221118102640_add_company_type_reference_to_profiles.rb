class AddCompanyTypeReferenceToProfiles < ActiveRecord::Migration[7.0]
  def change
    add_reference :profiles, :comtype, foreign_key: true
  end
end
