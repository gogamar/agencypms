class AddBedsOwnerIdToOffice < ActiveRecord::Migration[7.0]
  def change
    add_column :offices, :beds_owner_id, :string
    add_column :offices, :beds_key, :text
  end
end
