class AddMinStayAndIndexToAvailabilities < ActiveRecord::Migration[7.0]
  def change
    add_column :availabilities, :min_stay, :integer
    add_index :availabilities, :date
  end
end
