class CreateRenters < ActiveRecord::Migration[7.0]
  def change
    create_table :renters do |t|
      t.string :fullname
      t.string :address
      t.string :document
      t.string :account
      t.string :language
      t.references :rental, foreign_key: true

      t.timestamps
    end
  end
end
