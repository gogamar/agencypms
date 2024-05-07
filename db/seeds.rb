# require 'open-uri'
# require 'nokogiri'

all_vrentals = Vrental.all
barcelona_office = Office.where("name ILIKE ?", "%barcelona%").first
barcelona_vrentals = barcelona_office.vrentals
estartit_office = Office.where("name ILIKE ?", "%estartit%").first
estartit_vrentals = estartit_office.vrentals

# barcelona_tourist_apts = barcelona_vrentals.where(rental_term: "short_term")
# barcelona_tourist_interiors = barcelona_tourist_apts.where("name ILIKE ?", "%interior%")
# barcelona_tourist_exteriors = barcelona_tourist_apts.where("name ILIKE ?", "%exterior%")

# barcelona_monthly_apts = barcelona_vrentals.where(rental_term: "medium_term")
# barcelona_gaudi_monthly_apts = barcelona_monthly_apts.where.not("name ILIKE ?", "%tarradellas%")
# barcelona_gaudi_monthly_interiors = barcelona_gaudi_monthly_apts.where("name ILIKE ?", "%interior%")
# barcelona_gaudi_monthly_exteriors = barcelona_gaudi_monthly_apts.where("name ILIKE ?", "%exterior%")
barcelona_rate_group = Vrgroup.where("name ILIKE ?", "%gaud%")

# barcelona_tourist_apts.each do |vrental|
#   vrental.price_per = 'night'
#   vrental.weekly_discount = 10
#   vrental.save!
# end

# tourist_rate_master = Vrental.find_by(beds_prop_id: "22729")
# tourist_exterior_avail_master = Vrental.find_by(beds_prop_id: "22729")
# tourist_interior_avail_master = Vrental.find_by(beds_prop_id: "31422")

# barcelona_tourist_apts.where.not(beds_prop_id: "22729").each do |vrental|
#   vrental.rate_master_id = tourist_rate_master.id
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
#   vrental.save!
# end

# monthly_rate_master = Vrental.find_by(beds_prop_id: "23801")
# monthly_exterior_avail_master = Vrental.find_by(beds_prop_id: "23801")
# monthly_interiors_avail_master = Vrental.find_by(beds_prop_id: "31425")

# barcelona_gaudi_monthly_apts.where.not(beds_prop_id: "23801").each do |vrental|
#   vrental.rate_master_id = monthly_rate_master.id
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

# @company = Company.first
# Statement.all.each do |statement|
#   statement.update(company: @company)
# end
# Invoice.all.each do |invoice|
#   invoice.update(company: @company)
# end
# Vragreement.all.each do |vragreement|
#   vragreement.update(company: @company)
# end

# city tax

# towns = Town.all

# towns.each do |town|
#   town.update(city_tax: 0.99)
# end

# Town.find_by(name: "Barcelona").update(city_tax: 5.50)

# puts "Updated towns with city tax!"


# vrentals_with_weekly_rates = Vrental.where(price_per: "week")
# vrentals_with_weekly_rates.each do |vrental|
#   vrental.rates.where.not(pricenight: nil).where(priceweek: nil).destroy_all
#   vrental.rates.where.not(priceweek: nil).where(pricenight: nil).each do |rate|
#     rate.update(pricenight: rate.calculate_pricenight)
#   end
# end

# puts "Destroyed all rates for vrentals that have price_per 'week' and have a rate with pricenight set and priceweek nil"

# all_vrentals.each do |vrental|
#   if vrental.office.present? && vrental.prop_key.present?
#     VrentalApiService.new(vrental).update_vrental_from_beds
#     puts "Updated #{vrental.name} from beds"
#     puts "The property type is #{vrental.property_type}"
#   end
# end
# puts "Updated all vrentals from beds!"

# all_vrentals.each do |vrental|
#   ["ca", "en", "es", "fr"].each do |locale|
#     description_locale = vrental.send("description_#{locale}")
#     short_description_locale = vrental.send("short_description_#{locale}")
#     if description_locale.present?
#       # && short_description_locale.blank?
#       description_locale.gsub!(/HUT[\w-]+\s*/, '')
#       first_500_characters = description_locale[0, 500]
#       last_punctuation_index = first_500_characters.rindex(/[.!?]/)

#       if last_punctuation_index
#         text_before_last_punctuation = description_locale[0..last_punctuation_index].strip
#         text_after_last_punctuation = description_locale[(last_punctuation_index + 1)..-1]
#         vrental.update("short_description_#{locale}" => text_before_last_punctuation)
#         vrental.update("description_#{locale}" => text_after_last_punctuation)
#       end
#       puts "Updated short_description_#{locale} and description_#{locale} for #{vrental.name}"
#     end
#   end
# end

# all_vrentals.each do |vrental|
#   if vrental.office.present? && vrental.prop_key.present?
#     VrentalApiService.new(vrental).update_vrental_on_beds
#     puts "Updated #{vrental.name} on beds"
#   end
# end
# puts "Updated all vrentals on beds!"

# Feature.find_or_create_by(name: "dryer", highlight: false, company_id: Company.where(active: true).first.id)
# Feature.find_or_create_by(name: "heating", highlight: false, company_id: Company.where(active: true).first.id)

# puts "Created dryer and heating features"

# Review.all.each do |review|
#   review.update(source: "airbnb")
# end

# estartit = Office.find(1)
# estartit_active_vrentals = estartit.vrentals.where(status: "active")
# estartit_no_reviews = estartit_active_vrentals.left_outer_joins(:reviews).where(reviews: { id: nil })
# estartit_no_reviews.each do |vrental|
#   if vrental.prop_key.present? && vrental.airbnb_listing_id.present?
#     vrental.get_reviews_from_airbnb
#   end
#   sleep 3
# end

# barcelona = Office.find(2)
# barcelona_active_vrentals = barcelona.vrentals.where(status: "active")
# barcelona_no_reviews = barcelona_active_vrentals.left_outer_joins(:reviews).where(reviews: { id: nil })
# barcelona_no_reviews.each do |vrental|
#   if vrental.prop_key.present? && vrental.airbnb_listing_id.present?
#     vrental.get_reviews_from_airbnb
#   end
#   sleep 3
# end

# gaudi_group = Vrgroup.where("name ILIKE ?", "%gaud%").first
# monthly_group = Vrgroup.find_or_create_by(name: "Pisos mensuals", office_id: barcelona_office.id)

# barcelona_monthly_apts.each do |vrental|
#   monthly_group.vrentals << vrental
#   puts "Added #{vrental.name} to monthly group"
# end

# barcelona_gaudi_apartments = barcelona_vrentals.where.not("name ILIKE ?", "%tarradellas%")

# barcelona_gaudi_apartments.each do |vrental|
#   gaudi_group.vrentals << vrental
#   puts "Added #{vrental.name} to gaudi group"
# end

# all_vrentals.update_all(featured: false)
# barcelona_vrentals.each do |vrental|
#   VrentalApiService.new(vrental).get_bookings_from_beds(Date.today)
#   puts "Got bookings for #{vrental.name}"
# end

# estartit_vrentals.update_all(no_checkin: 0)
# barcelona_vrentals.update_all(control_restrictions: "rates")
# estartit_vrentals.update_all(control_restrictions: "calendar_beds24")
# barcelona_rate_group.update(rate_group: true)
# owners = Owner.all

# owners.each do |owner|
#   if owner.company_name.present?
#     words = owner.company_name.split(' ')
#     first_word_is_title = words[0].include?('.')

#     if first_word_is_title
#       owner.title = words[0]
#       owner.firstname = words[1]
#       owner.lastname = words[2..-1].join(' ')
#       owner.company_name = nil
#       if owner.user.present?
#         owner.user.title = words[0]
#         owner.user.firstname = words[1]
#         owner.user.lastname = words[2..-1].join(' ')
#       end
#     elsif words.length <= 3
#       owner.firstname = words[0]
#       owner.lastname = words[1..-1].join(' ')
#       owner.company_name = nil
#       if owner.user.present?
#         owner.user.firstname = words[0]
#         owner.user.lastname = words[1..-1].join(' ')
#       end
#     else
#       if owner.user.present?
#         owner.user.company_name = owner.company_name
#       end
#     end

#     # Save changes with error handling
#     unless owner.save
#       puts "Error saving Owner record: #{owner.errors.full_messages}"
#     end

#     if owner.user.present?
#       unless owner.user.save
#         puts "Error saving User record for Owner: #{owner.user.errors.full_messages}"
#       end
#     end
#   end

#   if owner.title.present?
#     if owner.title == "Sr."
#       owner.title = "mr"
#     elsif owner.title == "Sra."
#       owner.title = "mrs"
#     end

#     # Save changes with error handling
#     unless owner.save
#       puts "Error saving Owner record after title update: #{owner.errors.full_messages}"
#     end
#   end
# end

# costa_brava_feeds = Feed.where("name ILIKE ?", "%costa brava%")
# costa_brava_feeds.each do |feed|
#   xml = HTTParty.get(feed.url).body
#   parsed_xml = Feedjira.parse(xml)

#   puts "Getting posts for #{feed.name}..."

#   if parsed_xml.entries.any?
#     parsed_xml.entries.each do |entry|
#       decoded_summary = CGI.unescapeHTML(entry.summary)

#       puts "entry.url: #{entry.url}"

#       begin
#         doc = Nokogiri::HTML(URI.open(entry.url))
#       rescue StandardError => e
#         puts "Error: #{e.message}"
#       end
#       parraf = doc.css('p').first.text
#       puts "paraf: #{parraf}"


#       parsed_uri = URI.parse(entry.url)
#       domain = parsed_uri.host

#       # puts "entry: #{entry.inspect}"

#       # existing_post = Post.find_by(url: entry.url)
#       # next if existing_post

#     #   Post.create(
#     #     "title_#{feed.language}": entry.title,
#     #     "content_#{feed.language}": decoded_summary,
#     #     published_at: entry.published,
#     #     url: entry.url,
#     #     category_id: feed.category_id,
#     #     user_id: User.where(role: "admin").first.id,
#     #     image_url: entry.image,
#     #     feed_id: feed.id,
#     #     source: domain
#     #   )
#     end
#   end
# end

# estartit_vrentals.each do |vrental|
#   vrental.update(min_advance: 48)
#   if vrental.status == "active" && vrental.prop_key.present? && vrental.future_rates.exists?
#     vrental.rates.each do |rate|
#       rate.update(min_advance: 2)
#     end
#     VrentalApiService.new(vrental).send_rates_to_beds
#     puts "Sent rates for #{vrental.name} with 2 nights min advance"
#   end
# end

estartit_vrentals_with_wifi = estartit_vrentals.joins(:features).where(features: { name: "wifi" }).distinct

estartit_vrentals_without_wifi = estartit_vrentals.where.not(id: estartit_vrentals_with_wifi.pluck(:id))

puts "estartit_vrentals_without_wifi are: #{estartit_vrentals_without_wifi.pluck(:name)}"

estartit_vrentals_without_wifi.last do |vrental|
  puts "Updating property #{vrental.name} on Beds24"
  client = BedsHelper::Beds.new(vrental.office.beds_key)
  begin
      bedsrental = [
          {
            action: "modify",
            roomTypes: [
              {
                action: "modify",
                roomId: vrental.beds_room_id,
                "template1": "NO_WIFI"
              }
            ]
          }
      ]
      client.set_property(vrental.prop_key, setProperty: bedsrental)
  rescue => e
    puts "Error exporting property #{vrental.name}: #{e.message}"
  end
  sleep 2
end
