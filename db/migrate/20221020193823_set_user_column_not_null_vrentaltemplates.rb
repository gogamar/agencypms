class SetUserColumnNotNullVrentaltemplates < ActiveRecord::Migration[7.0]
  def change
    change_column_null :vrentaltemplates, :user_id, false
  end
end
