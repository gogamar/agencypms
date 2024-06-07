class AddWifiPassToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :wifi_pass, :text
  end
end
