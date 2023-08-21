class CreatePages < ActiveRecord::Migration[7.0]
  def change
    create_table :pages do |t|
      t.string :title_en
      t.string :title_ca
      t.string :title_es
      t.string :title_fr
      t.string :page_type
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
