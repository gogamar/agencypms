class CreateVragreements < ActiveRecord::Migration[7.0]
  def change
    create_table :vragreements do |t|
      t.date :signdate
      t.string :place
      t.date :start_date
      t.date :end_date
      t.references :vrowner, foreign_key: true
      t.references :vrentaltemplate, foreign_key: true
      t.references :vrental, foreign_key: true

      t.timestamps
    end
  end
end
