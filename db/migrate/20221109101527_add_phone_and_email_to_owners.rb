class AddPhoneAndEmailToOwners < ActiveRecord::Migration[7.0]
  def change
    add_column :owners, :phone, :string
    add_column :owners, :email, :string
  end
end
