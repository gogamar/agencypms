class AddColumnsToBedrooms < ActiveRecord::Migration[7.0]
  def change
    add_column :bedrooms, :bed_count, :integer
    add_column :vrentals, :bedroom_count, :integer
    add_column :vrentals, :bathroom_count, :integer
  end
end
