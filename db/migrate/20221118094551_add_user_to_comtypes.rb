class AddUserToComtypes < ActiveRecord::Migration[7.0]
  def change
    add_reference :comtypes, :user, foreign_key: true
  end
end
