barcelona_vrentals = Office.where("name ILIKE ?", "%barcelona%").first.vrentals
estartit_vrentals = Office.where("name ILIKE ?", "%estartit%").first.vrentals

barcelona_tourist_apts = barcelona_vrentals.where(rental_term: "short_term")
barcelona_tourist_interiors = barcelona_tourist_apts.where("name ILIKE ?", "%interior%")
barcelona_tourist_exteriors = barcelona_tourist_apts.where("name ILIKE ?", "%exterior%")

barcelona_monthly_apts = barcelona_vrentals.where(rental_term: "medium_term")
barcelona_monthly_interiors = barcelona_monthly_apts.where("name ILIKE ?", "%interior%")
barcelona_monthly_exteriors = barcelona_monthly_apts.where("name ILIKE ?", "%exterior%")

# barcelona_tourist_apts.each do |vrental|
#   vrental.price_per = 'night'
#   vrental.weekly_discount = 10
#   vrental.weekly_discount_included = false
#   vrental.save!
# end

# master_vrental = Vrental.find_by(beds_prop_id: "22729")

# master_vrental.update(master_rate: true)

# barcelona_tourist_apts.where.not(beds_prop_id: "22729").each do |vrental|
#   vrental.master_vrental_id = master_vrental.id
#   vrental.save!
# end

# barcelona_tourist_interiors.each do |vrental|
#   vrental.rate_offset = -7.00
#   vrental.rate_offset_type = "1"
#   vrental.save!
# end

# estartit_vrentals.each do |vrental|
#   vrental.price_per = 'week'
#   vrental.weekly_discount = 10
#   vrental.weekly_discount_included = true
#   vrental.save!
# end

master_monthly_vrental = Vrental.find_by(beds_prop_id: "23801")

master_monthly_vrental.update(master_rate: true)

barcelona_monthly_apts.where.not(beds_prop_id: "23801").each do |vrental|
  vrental.master_vrental_id = master_monthly_vrental.id
  vrental.save!
end

barcelona_monthly_interiors.each do |vrental|
  vrental.rate_offset = -10.00
  vrental.rate_offset_type = "1"
  vrental.save!
end

puts "Done!"
