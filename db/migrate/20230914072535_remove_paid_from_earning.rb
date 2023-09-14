class RemovePaidFromEarning < ActiveRecord::Migration[7.0]
  def change
    remove_column :earnings, :paid, :boolean
  end
end
