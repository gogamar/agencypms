class RemoveUserFromVrentals < ActiveRecord::Migration[7.0]
  def change
    remove_reference :vrentals, :user
  end
end
