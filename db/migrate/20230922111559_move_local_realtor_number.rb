class MoveLocalRealtorNumber < ActiveRecord::Migration[7.0]
  def change
    remove_column :companies, :local_realtor_number, :string
    add_column :offices, :local_realtor_number, :string
  end
end
