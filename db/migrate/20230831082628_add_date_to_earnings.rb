class AddDateToEarnings < ActiveRecord::Migration[7.0]
  def change
    add_column :earnings, :date, :date
  end
end
