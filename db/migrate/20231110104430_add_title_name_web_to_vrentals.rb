class AddTitleNameWebToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :title_ca, :string
    add_column :vrentals, :title_es, :string
    add_column :vrentals, :title_fr, :string
    add_column :vrentals, :title_en, :string
    add_column :vrentals, :name_on_web, :boolean, default: false
  end
end
