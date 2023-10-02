class CreateImageUrls < ActiveRecord::Migration[7.0]
  def change
    create_table :image_urls do |t|
      t.string :url
      t.integer :order

      t.timestamps
    end
  end
end
