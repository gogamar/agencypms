# all_vrentals = Vrental.all
# barcelona_vrentals = Office.where("name ILIKE ?", "%barcelona%").first.vrentals
# estartit_vrentals = Office.where("name ILIKE ?", "%estartit%").first.vrentals

# barcelona_tourist_apts = barcelona_vrentals.where(rental_term: "short_term")
# barcelona_tourist_interiors = barcelona_tourist_apts.where("name ILIKE ?", "%interior%")
# barcelona_tourist_exteriors = barcelona_tourist_apts.where("name ILIKE ?", "%exterior%")

# barcelona_monthly_apts = barcelona_vrentals.where(rental_term: "medium_term")
# barcelona_gaudi_monthly_apts = barcelona_monthly_apts.where.not("name ILIKE ?", "%tarradellas%")
# barcelona_gaudi_monthly_interiors = barcelona_gaudi_monthly_apts.where("name ILIKE ?", "%interior%")
# barcelona_gaudi_monthly_exteriors = barcelona_gaudi_monthly_apts.where("name ILIKE ?", "%exterior%")

# barcelona_tourist_apts.each do |vrental|
#   vrental.price_per = 'night'
#   vrental.weekly_discount = 10
#   vrental.weekly_discount_included = false
#   vrental.save!
# end

# tourist_rate_master = Vrental.find_by(beds_prop_id: "22729")
# tourist_exterior_avail_master = Vrental.find_by(beds_prop_id: "22729")
# tourist_interior_avail_master = Vrental.find_by(beds_prop_id: "31422")

# barcelona_tourist_apts.where.not(beds_prop_id: "22729").each do |vrental|
#   vrental.rate_master_id = tourist_rate_master.id
#   vrental.save!
# end

# barcelona_tourist_exteriors.where.not(beds_prop_id: "22730").each do |vrental|
#   vrental.availability_master_id = tourist_exterior_avail_master.id
#   vrental.save!
# end

# barcelona_tourist_interiors.where.not(beds_prop_id: "31422").each do |vrental|
#   vrental.availability_master_id = tourist_interior_avail_master.id
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

# monthly_rate_master = Vrental.find_by(beds_prop_id: "23801")
# monthly_exterior_avail_master = Vrental.find_by(beds_prop_id: "23801")
# monthly_interiors_avail_master = Vrental.find_by(beds_prop_id: "31425")

# barcelona_gaudi_monthly_apts.where.not(beds_prop_id: "23801").each do |vrental|
#   vrental.rate_master_id = monthly_rate_master.id
#   vrental.save!
# end

# barcelona_gaudi_monthly_exteriors.where.not(beds_prop_id: "23801").each do |vrental|
#   vrental.availability_master_id = monthly_exterior_avail_master.id
#   vrental.save!
# end

# barcelona_gaudi_monthly_interiors.where.not(beds_prop_id: "31425").each do |vrental|
#   vrental.availability_master_id = monthly_interiors_avail_master.id
#   vrental.save!
# end

# barcelona_gaudi_monthly_interiors.each do |vrental|
#   vrental.rate_offset = -10.00
#   vrental.rate_offset_type = "1"
#   vrental.save!
# end

# all_vrentals.each do |vrental|
#   vrental.update(unit_number: 1)
# end

# barcelona_tourist_interiors.each do |vrental|
#   vrental.update(unit_number: 9)
# end

# barcelona_tourist_exteriors.each do |vrental|
#   vrental.update(unit_number: 6)
# end

# barcelona_gaudi_monthly_interiors.each do |vrental|
#   vrental.update(unit_number: 5)
# end

# barcelona_gaudi_monthly_exteriors.each do |vrental|
#   vrental.update(unit_number: 4)
# end

# barcelona_monthly_apts.each do |vrental|
#   VrentalApiService.new(vrental).get_bookings_from_beds
#   sleep 3
#   puts "Got bookings for #{vrental.name}"
# end

# barcelona_monthly_apts.each do |vrental|
#   VrentalApiService.new(vrental).prevent_gaps_on_beds(5)
#   sleep 3
#   puts "Prevented gaps for #{vrental.name}"
# end

# Add company to statements, invoices and vragreements

@company = Company.first
Statement.all.each do |statement|
  statement.update(company: @company)
end
Invoice.all.each do |invoice|
  invoice.update(company: @company)
end
Vragreement.all.each do |vragreement|
  vragreement.update(company: @company)
end

puts "Done!"
