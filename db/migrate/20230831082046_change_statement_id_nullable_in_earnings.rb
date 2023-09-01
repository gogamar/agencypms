class ChangeStatementIdNullableInEarnings < ActiveRecord::Migration[7.0]
  def change
    change_column_null :earnings, :statement_id, true
  end
end
