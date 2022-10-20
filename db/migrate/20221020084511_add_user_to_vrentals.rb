class AddUserToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_reference :vrentals, :user, foreign_key: true
  end
end
