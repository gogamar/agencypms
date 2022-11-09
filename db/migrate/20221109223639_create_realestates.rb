class CreateRealestates < ActiveRecord::Migration[7.0]
  def change
    create_table :realestates do |t|
      t.string :address
      t.string :city
      t.string :cadastre
      t.string :energy
      t.text :description
      t.string :status
      t.references :user, null: false, foreign_key: true
      t.references :seller, foreign_key: true

      t.timestamps
    end
  end
end
