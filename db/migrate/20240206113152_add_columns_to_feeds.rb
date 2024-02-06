class AddColumnsToFeeds < ActiveRecord::Migration[7.0]
  def change
    add_column :feeds, :language, :string
    add_reference :feeds, :category, foreign_key: true
    add_column :posts, :source, :string
    add_column :posts, :guid, :string
    add_column :posts, :hidden, :boolean, default: false
  end
end
