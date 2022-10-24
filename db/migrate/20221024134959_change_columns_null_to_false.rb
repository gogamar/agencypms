class ChangeColumnsNullToFalse < ActiveRecord::Migration[7.0]
  def change
    change_column_null :vrowners, :user_id, false
    change_column_null :rentaltemplates, :user_id, false
  end
end
