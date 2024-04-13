class AddMonthlyOptionToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :monthly_option, :boolean, default: false
  end
end
