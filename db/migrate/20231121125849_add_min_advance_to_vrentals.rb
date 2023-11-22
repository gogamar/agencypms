class AddMinAdvanceToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :min_advance, :integer, default: 0
  end
end
