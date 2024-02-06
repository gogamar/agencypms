class CreateFeedsAndAddColumnsToPosts < ActiveRecord::Migration[7.0]
  def change
    create_table :feeds do |t|
      t.string :name
      t.string :url
      t.string :description

      t.timestamps
    end

    add_reference :posts, :feed, foreign_key: true
    add_column :posts, :published_at, :datetime
    add_column :posts, :url, :string
    add_column :posts, :image_url, :string
  end
end
