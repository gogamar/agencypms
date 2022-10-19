class CreateAgreements < ActiveRecord::Migration[7.0]
  def change
    create_table :agreements do |t|
      t.date :start_date
      t.date :end_date
      t.float :price
      t.float :deposit
      t.text :contentarea
      t.string :duration
      t.string :pricetext
      t.string :place
      t.date :signdate
      t.references :owner, foreign_key: true
      t.references :renter, foreign_key: true
      t.references :rentaltemplate, foreign_key: true
      t.references :rental, foreign_key: true

      t.timestamps
    end
  end
end
