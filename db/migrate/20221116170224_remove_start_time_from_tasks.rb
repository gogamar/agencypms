class RemoveStartTimeFromTasks < ActiveRecord::Migration[7.0]
  def change
    remove_column :tasks, :start_time
  end
end
