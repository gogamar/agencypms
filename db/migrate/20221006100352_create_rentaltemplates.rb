class CreateRentaltemplates < ActiveRecord::Migration[7.0]
  def change
    create_table :rentaltemplates do |t|
      t.string :title
      t.string :language
      t.text :text

      t.timestamps
    end
  end
end
