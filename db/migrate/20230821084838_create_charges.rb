class CreateCharges < ActiveRecord::Migration[7.0]
  def change
    create_table :charges do |t|
      t.string :description
      t.integer :quantity
      t.decimal :price
      t.references :booking, null: false, foreign_key: true

      t.timestamps
    end
  end
end
