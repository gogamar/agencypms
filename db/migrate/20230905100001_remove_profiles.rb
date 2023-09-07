class RemoveProfiles < ActiveRecord::Migration[7.0]
  def change
    drop_table :contracts, force: :cascade
    drop_table :rentals, force: :cascade
    drop_table :rentaltemplates, force: :cascade
    drop_table :rstemplates, force: :cascade
    drop_table :agreements, force: :cascade
    drop_table :buyers, force: :cascade
    drop_table :owners, force: :cascade
    drop_table :profiles, force: :cascade
    drop_table :realestates, force: :cascade
    drop_table :sellers, force: :cascade
    drop_table :renters, force: :cascade
    drop_table :com_types, force: :cascade
  end
end
