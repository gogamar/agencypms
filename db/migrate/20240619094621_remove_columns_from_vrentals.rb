class RemoveColumnsFromVrentals < ActiveRecord::Migration[7.0]
  def change
    remove_reference :vrentals, :cleaning_company
    remove_column :vrentals, :cleaning_hours
  end
end
