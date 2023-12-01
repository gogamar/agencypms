class DropTablePages < ActiveRecord::Migration[7.0]
  def change
    drop_table :blocks
    drop_table :pages
  end
end
