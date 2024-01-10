class CreateJoinTableVrentalsVrgroups < ActiveRecord::Migration[7.0]
  def change
    create_join_table :vrentals, :vrgroups do |t|
    end

    remove_column :vrentals, :vrgroup_id, :bigint
  end
end
