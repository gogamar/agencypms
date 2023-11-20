class AddColumnsToRates < ActiveRecord::Migration[7.0]
  def change
    add_column :rates, :max_stay, :integer, default: 365, after: :min_stay
    add_column :rates, :min_advance, :integer, default: 0, after: :max_stay
    add_column :rates, :restriction, :string, default: "normal", after: :min_advance
  end
end
