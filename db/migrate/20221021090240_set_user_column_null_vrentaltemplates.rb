class SetUserColumnNullVrentaltemplates < ActiveRecord::Migration[7.0]
  def change
    change_column_null :vrentaltemplates, :user_id, true
  end
end
