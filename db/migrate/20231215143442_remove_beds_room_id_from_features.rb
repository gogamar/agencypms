class RemoveBedsRoomIdFromFeatures < ActiveRecord::Migration[7.0]
  def change
    remove_column :features, :beds_room_id
  end
end
