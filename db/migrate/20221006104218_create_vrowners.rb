class CreateOwners < ActiveRecord::Migration[7.0]
  def change
    create_table :vrowners do |t|
      t.string :fullname
      t.string :language
      t.string :document
      t.string :address
      t.string :email
      t.string :phone
      t.string :account
      t.string :beds_room_id

      t.timestamps
    end
  end
end
