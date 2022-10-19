class CreateRentals < ActiveRecord::Migration[7.0]
  def change
    create_table :rentals do |t|
      t.string :address
      t.string :cadastre
      t.string :energy
      t.string :city
      t.text :description
      t.references :owner, foreign_key: true

      t.timestamps
    end
  end
end
