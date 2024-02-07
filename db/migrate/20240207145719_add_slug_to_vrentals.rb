class AddSlugToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :slug, :string
    add_index :vrentals, :slug, unique: true
  end
end
