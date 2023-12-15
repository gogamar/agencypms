class ModifyColumnsVrentals < ActiveRecord::Migration[7.0]
  def change
    add_column :vrentals, :cleaning_fee, :decimal
    add_column :vrentals, :cut_off_hour, :integer
    add_column :vrentals, :checkin_start_hour, :time
    add_column :vrentals, :checkin_end_hour, :time
    add_column :vrentals, :checkout_end_hour, :time
    add_column :vrentals, :short_description_en, :text
    add_column :vrentals, :short_description_ca, :text
    add_column :vrentals, :short_description_es, :text
    add_column :vrentals, :short_description_fr, :text
    add_column :vrentals, :access_text_en, :text
    add_column :vrentals, :access_text_ca, :text
    add_column :vrentals, :access_text_es, :text
    add_column :vrentals, :access_text_fr, :text
    add_column :vrentals, :house_rules_en, :text
    add_column :vrentals, :house_rules_ca, :text
    add_column :vrentals, :house_rules_es, :text
    add_column :vrentals, :house_rules_fr, :text
    remove_column :vrentals, :weekly_discount_included
    remove_column :rates, :weekly_rate_id
  end
end
