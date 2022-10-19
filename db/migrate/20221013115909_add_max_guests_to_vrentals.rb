class AddMaxGuestsToVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :max_guests, :integer
  end
end
