class ChangeUserColumnToNullFalse < ActiveRecord::Migration[7.0]
  def change
    change_column_null :vrentals, :user_id, false
    change_column_null :rentals, :user_id, false
    change_column_null :vrentaltemplates, :user_id, false
  end
end
