class AddTownToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :town, :string
  end
end
