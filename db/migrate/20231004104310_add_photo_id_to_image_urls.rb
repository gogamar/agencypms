class AddPhotoIdToImageUrls < ActiveRecord::Migration[7.0]
  def change
    add_column :image_urls, :photo_id, :integer
    add_index :image_urls, :photo_id
  end
end
