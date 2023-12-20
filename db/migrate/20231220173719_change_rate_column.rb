class ChangeRateColumn < ActiveRecord::Migration[7.0]
  def change
    remove_column :reviews, :rate
    add_column :reviews, :rating, :integer
  end
end
