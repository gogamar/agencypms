class AddDescriptionEsToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :description_es, :text
  end
end
