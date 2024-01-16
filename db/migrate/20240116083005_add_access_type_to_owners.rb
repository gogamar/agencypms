class AddAccessTypeToOwners < ActiveRecord::Migration[7.0]
  def change
    add_column :owners, :access_type, :string, default: 'basic'
  end
end
