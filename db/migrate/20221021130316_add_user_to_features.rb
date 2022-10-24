class AddUserToFeatures < ActiveRecord::Migration[7.0]
  def change
    add_reference :features, :user, foreign_key: true
  end
end
