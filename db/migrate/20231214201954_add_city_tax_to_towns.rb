class AddCityTaxToTowns < ActiveRecord::Migration[7.0]
  def change
    add_column :towns, :city_tax, :decimal, precision: 10, scale: 2
  end
end
