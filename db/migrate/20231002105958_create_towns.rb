class CreateTowns < ActiveRecord::Migration[7.0]
  def change
    create_table :towns do |t|
      t.string :name
      t.text :description_ca
      t.text :description_es
      t.text :description_en
      t.text :description_fr

      t.timestamps
    end

    add_reference :vrentals, :town, foreign_key: true
  end
end
