class CreateEmailLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :email_logs do |t|
      t.string :recipient_email
      t.string :email_type
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
