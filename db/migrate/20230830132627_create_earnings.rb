class CreateEarnings < ActiveRecord::Migration[7.0]
  def change
    create_table :earnings do |t|
      t.string :description
      t.decimal :discount
      t.decimal :amount
      t.references :statement, null: false, foreign_key: true

      t.timestamps
    end
  end
end
