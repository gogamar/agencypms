class RemoveUserFromVrentaltemplate < ActiveRecord::Migration[7.0]
  def change
    remove_reference :vrentaltemplates, :user
    add_reference :vrentaltemplates, :company, foreign_key: true
    remove_reference :features, :user
    add_reference :features, :company, foreign_key: true
    change_column :owners, :user_id, :bigint, null: true
  end
end
