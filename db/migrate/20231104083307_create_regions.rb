class CreateRegions < ActiveRecord::Migration[7.0]
  def change
    create_table :regions do |t|
      t.string :name_ca
      t.string :name_es
      t.string :name_fr
      t.string :name_en
      t.text :description_ca
      t.text :description_es
      t.text :description_fr
      t.text :description_en

      t.timestamps
    end

    add_reference :towns, :region, foreign_key: true
  end
end
