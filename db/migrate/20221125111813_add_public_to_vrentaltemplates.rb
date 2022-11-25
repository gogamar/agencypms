class AddPublicToVrentaltemplates < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentaltemplates, :public, :boolean, default: false
  end
end
