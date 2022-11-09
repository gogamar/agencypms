class AddPhoneAndEmailToRenters < ActiveRecord::Migration[7.0]
  def change
    add_column :renters, :phone, :string
    add_column :renters, :email, :string
  end
end
