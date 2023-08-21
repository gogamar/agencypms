class CreateTourists < ActiveRecord::Migration[7.0]
  def change
    create_table :tourists do |t|
      t.string :firstname
      t.string :lastname
      t.string :phone
      t.string :email
      t.string :address
      t.string :country_code
      t.string :country
      t.string :document

      t.timestamps
    end
  end
end
