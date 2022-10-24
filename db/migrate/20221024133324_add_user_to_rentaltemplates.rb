class AddUserToRentaltemplates < ActiveRecord::Migration[7.0]
  def change
    add_reference :rentaltemplates, :user, null: true, foreign_key: true
  end
end
