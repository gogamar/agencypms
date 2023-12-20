class CreateReviews < ActiveRecord::Migration[7.0]
  def change
    create_table :reviews do |t|
      t.string :review_id
      t.string :client_name
      t.string :client_photo_url
      t.string :client_location
      t.string :review_time
      t.string :rate
      t.text :comment
      t.references :vrental, null: false, foreign_key: true

      t.timestamps
    end
  end
end
