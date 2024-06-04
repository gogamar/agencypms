class AddRoleToUsersRenameVrowner < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :role, :integer, default: 0
    User.where(admin: true).update_all(role: 2)
    remove_column :users, :admin
  end
end
