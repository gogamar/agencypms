class ChangeColumnsNullToFalse < ActiveRecord::Migration[7.0]
  def change
    change_column_null :owners, :user_id, false
  end
end
