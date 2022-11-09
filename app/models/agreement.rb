class Agreement < ApplicationRecord
  belongs_to :rentaltemplate
  belongs_to :rental
  belongs_to :renter
  validates :rental_id, presence: true
  validates :rentaltemplate_id, presence: true
  has_many_attached :photos


  def self.parse_template(template, attrs = {})
    result = template
    attrs.each { |field, value| result.gsub!("{{#{field}}}", value) }
    # remove anything that resembles a field but did not match a known field name
    result.gsub!(/\{\{\.w+\}\}/, '')
    return result
  end
end
