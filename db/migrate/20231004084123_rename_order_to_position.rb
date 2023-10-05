class RenameOrderToPosition < ActiveRecord::Migration[7.0]
  def change
    rename_column :image_urls, :order, :position
  end
end
