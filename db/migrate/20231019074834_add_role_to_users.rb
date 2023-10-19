class AddRoleToUsers < ActiveRecord::Migration[7.0]
  def up
    add_column :users, :role, :integer, default: 0
    User.where(admin: true).update_all(role: 2)
    remove_column :users, :admin
  end

  def down
    add_column :users, :admin, :boolean, default: false, null: false
    User.where(role: 2).update_all(admin: true)
    remove_column :users, :role
  end
end
