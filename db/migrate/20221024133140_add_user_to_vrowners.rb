class AddUserToVrowners < ActiveRecord::Migration[7.0]
  def change
    add_reference :vrowners, :user, null: true, foreign_key: true
  end
end
