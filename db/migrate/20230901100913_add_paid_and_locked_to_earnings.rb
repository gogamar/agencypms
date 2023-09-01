class AddPaidAndLockedToEarnings < ActiveRecord::Migration[7.0]
  def change
    add_column :earnings, :paid, :boolean, default: false
    add_column :earnings, :locked, :boolean, default: false
  end
end
