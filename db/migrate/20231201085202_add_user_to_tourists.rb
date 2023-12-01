class AddUserToTourists < ActiveRecord::Migration[7.0]
  def change
    add_reference :tourists, :user, foreign_key: true
  end
end
