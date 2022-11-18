class RenameColumnComtypes < ActiveRecord::Migration[7.0]
  def change
    rename_column :comtypes, :type, :company_type
  end
end
