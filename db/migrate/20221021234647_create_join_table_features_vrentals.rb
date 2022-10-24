class CreateJoinTableFeaturesVrentals < ActiveRecord::Migration[7.0]
  def change
    create_join_table :features, :vrentals
  end
end
