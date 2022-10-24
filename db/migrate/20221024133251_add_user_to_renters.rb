class AddUserToRenters < ActiveRecord::Migration[7.0]
  def change
    add_reference :renters, :user, null: false, foreign_key: true
  end
end
