class RemoveEndTimeFromTasks < ActiveRecord::Migration[7.0]
  def change
    remove_column :tasks, :end_time
  end
end
