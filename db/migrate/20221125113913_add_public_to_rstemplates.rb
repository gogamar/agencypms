class AddPublicToRstemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :rstemplates, :public, :boolean, default: false
  end
end
