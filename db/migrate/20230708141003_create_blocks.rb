class CreateBlocks < ActiveRecord::Migration[7.0]
  def change
    create_table :blocks do |t|
      t.string :title_en
      t.string :title_ca
      t.string :title_es
      t.string :title_fr
      t.string :subtitle_en
      t.string :subtitle_ca
      t.string :subtitle_es
      t.string :subtitle_fr
      t.text :content_en
      t.text :content_ca
      t.text :content_es
      t.text :content_fr
      t.string :button_en
      t.string :button_ca
      t.string :button_es
      t.string :button_fr
      t.references :page, null: false, foreign_key: true

      t.timestamps
    end
  end
end
