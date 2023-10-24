class AddRoleToUsersRenameVrowner < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :role, :integer, default: 0
    User.where(admin: true).update_all(role: 2)
    remove_column :users, :admin
    rename_table :vrowners, :owners
    rename_column :vrentals, :vrowner_id, :owner_id
    rename_table :vrowner_payments, :owner_payments
  end
end
