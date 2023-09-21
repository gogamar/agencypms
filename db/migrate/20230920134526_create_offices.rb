class CreateOffices < ActiveRecord::Migration[7.0]
  def change
    create_table :offices do |t|
      t.string :name
      t.string :street
      t.string :city
      t.string :post_code
      t.string :region
      t.string :country
      t.string :phone
      t.string :mobile
      t.string :email
      t.string :website
      t.string :opening_hours
      t.string :manager
      t.references :company, null: false, foreign_key: true

      t.timestamps
    end
  end
end
