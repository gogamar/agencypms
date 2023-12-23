class ChangeReviews < ActiveRecord::Migration[7.0]
  def change
    remove_column :reviews, :review_time
    remove_column :reviews, :client_photo_url
    rename_column :reviews, :comment, :comment_ca
    add_column :reviews, :comment_en, :text
    add_column :reviews, :comment_es, :text
    add_column :reviews, :comment_fr, :text
    rename_column :reviews, :client_location
    add_column :reviews, :client_location_en, :string
    add_column :reviews, :client_location_es, :string
    add_column :reviews, :client_location_fr, :string
  end
end
