class CreateOwners < ActiveRecord::Migration[7.0]
  def change
    create_table :owners do |t|
      t.string :fullname
      t.string :address
      t.string :document
      t.string :account
      t.string :language

      t.timestamps
    end
  end
end
