class AddUserToVrentaltemplates < ActiveRecord::Migration[7.0]
  def change
    add_reference :vrentaltemplates, :user, foreign_key: true
  end
end
