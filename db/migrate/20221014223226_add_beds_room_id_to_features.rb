class AddBedsRoomIdToFeatures < ActiveRecord::Migration[7.0]
  def change
    add_column :features, :beds_room_id, :string
  end
end
