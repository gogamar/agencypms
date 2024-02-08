class AddMaxAdvanceColumnToRates < ActiveRecord::Migration[7.0]
  def change
    add_column :rates, :max_advance, :integer, default: 365
  end
end
