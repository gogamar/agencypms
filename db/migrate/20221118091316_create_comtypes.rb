class CreateComtypes < ActiveRecord::Migration[7.0]
  def change
    create_table :comtypes do |t|
      t.string :type

      t.timestamps
    end
  end
end
