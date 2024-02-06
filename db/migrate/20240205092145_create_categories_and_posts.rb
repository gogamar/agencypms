class CreateCategoriesAndPosts < ActiveRecord::Migration[7.0]
  def change
    create_table :categories do |t|
      t.string :name_ca
      t.string :name_es
      t.string :name_en
      t.string :name_fr

      t.timestamps
    end

    create_table :posts do |t|
      t.string :title_ca
      t.string :title_es
      t.string :title_en
      t.string :title_fr
      t.string :content_ca
      t.string :content_es
      t.string :content_en
      t.string :content_fr
      t.references :category, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
