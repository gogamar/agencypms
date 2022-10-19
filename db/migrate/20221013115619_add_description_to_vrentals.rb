class AddDescriptionToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :description, :text
  end
end
