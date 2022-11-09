class CreateRstemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :rstemplates do |t|
      t.string :title
      t.string :language
      t.text :text
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
