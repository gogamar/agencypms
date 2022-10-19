class AddStatusToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :status, :string
  end
end
