class AddStatements < ActiveRecord::Migration[7.0]
  def change
    create_table :invoices do |t|
      t.date :date
      t.string :location
      t.integer :number
      t.references :vrental, foreign_key: true

      t.timestamps
    end

    create_table :statements do |t|
      t.date :start_date
      t.date :end_date
      t.date :date
      t.string :location
      t.string :ref_number
      t.references :vrental, foreign_key: true
      t.references :invoice, foreign_key: true

      t.timestamps
    end

    create_table :expenses do |t|
      t.string :description
      t.decimal :amount
      t.string :expense_type
      t.string :expense_number
      t.string :expense_company
      t.references :vrental, foreign_key: true
      t.references :statement, foreign_key: true

      t.timestamps
    end

    create_table :owner_payments do |t|
      t.string :description
      t.decimal :amount
      t.date :date
      t.references :statement, foreign_key: true

      t.timestamps
    end
  end
end
