class AddAicatApiToProfile < ActiveRecord::Migration[7.0]
  def change
    add_column :profiles, :aicat, :string
    add_column :profiles, :api, :string
  end
end
