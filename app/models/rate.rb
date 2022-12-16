class Rate < ApplicationRecord
  belongs_to :vrental
  validates :firstnight, presence: true
  validates :lastnight, presence: true
  validates :lastnight, comparison: { greater_than: :firstnight }
  validates :firstnight, uniqueness: { scope: :vrental_id, message: 'Aquesta tarifa ja existeix.' }
  validates :lastnight, uniqueness: { scope: :vrental_id, message: 'Aquesta tarifa ja existeix.' }
  validates :min_stay, presence: true
  validates :arrival_day, presence: true
  validates :priceweek, presence: true


  def send_to_beds
    prop_key = self.vrental.prop_key

    new_beds24_rates = [
      {
      action: "new",
      roomId: "#{self.vrental.beds_room_id}",
      firstNight: "#{self.firstnight}",
      lastNight: "#{self.lastnight}",
      name: "Tarifa #{self.firstnight} - #{self.lastnight} amb 10% desc. setmanal",
      minNights: "0",
      minAdvance: "2",
      allowEnquiry: "1",
      pricesPer: "1",
      color: "#{SecureRandom.hex(3)}",
      roomPrice: "#{self.priceweek/6.295}",
      roomPriceEnable: "1",
      roomPriceGuests: "0",
      disc1Nights: "2",
      disc2Nights: "3",
      disc3Nights: "4",
      disc4Nights: "5",
      disc5Nights: "6",
      disc6Nights: "7",
      disc7Nights: "8",
      disc8Nights: "9",
      disc6Percent: "10.00"
      },
      {
      action: "new",
      roomId: "#{self.vrental.beds_room_id}",
      firstNight: "#{self.firstnight}",
      lastNight: "#{self.lastnight}",
      name: "Tarifa setmanal nomes sistachrentals.com #{self.firstnight} - #{self.lastnight}",
      minAdvance: "2",
      allowEnquiry: "1",
      pricesPer: "7",
      color: "#{SecureRandom.hex(3)}",
      roomPrice: "#{self.priceweek}",
      roomPriceEnable: "1",
      roomPriceGuests: "0",
      channel000: "1",
      channel999: "1",
      channel017: "0",
      channel046: "0",
      channel032: "0",
      channel027: "0",
      channel031: "0",
      channel052: "0",
      channel019: "0",
      channel002: "0",
      channel053: "0",
      channel059: "0",
      channel066: "0",
      channel014: "0",
      channel033: "0",
      channel012: "0",
      channel073: "0",
      channel013: "0",
      channel078: "0",
      channel044: "0",
      channel064: "0",
      channel024: "0",
      channel036: "0",
      channel057: "0",
      channel072: "0",
      channel035: "0",
      channel087: "0",
      channel051: "0",
      channel042: "0",
      channel023: "0",
      channel086: "0",
      channel050: "0",
      channel083: "0",
      channel056: "0",
      channel076: "0",
      channel055: "0",
      channel063: "0",
      channel030: "0",
      channel034: "0"
      }
    ]

    auth_token = ENV["BEDSKEY"]
    client = BedsHelper::Beds.new(auth_token)
    client.set_rates(prop_key, setRates: new_beds24_rates)
  end
end
