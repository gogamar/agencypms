class CreateProfiles < ActiveRecord::Migration[7.0]
  def change
    create_table :profiles do |t|
      t.string :businessname
      t.string :companyname
      t.string :address
      t.string :vat
      t.string :companytype
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
