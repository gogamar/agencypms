class CreateContracts < ActiveRecord::Migration[7.0]
  def change
    create_table :contracts do |t|
      t.float :price
      t.text :contentarea
      t.string :pricetext
      t.string :place
      t.date :signdate
      t.references :realestate, null: false, foreign_key: true
      t.references :rstemplate, foreign_key: true
      t.references :buyer, foreign_key: true

      t.timestamps
    end
  end
end
