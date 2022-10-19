class AddDescriptionFrToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :description_fr, :text
  end
end
