class Vragreement < ApplicationRecord
  belongs_to :vrentaltemplate
  belongs_to :vrental
  validates :vrental_id, presence: true
  validates :vrentaltemplate_id, presence: true
  # validates :vrental_id, uniqueness: { scope: :year, message: "Un contracte per any!" }
  has_many_attached :photos

  def self.parse_template(template, attrs = {})
    result = template
    attrs.each { |field, value| result.gsub!("{{#{field}}}", value) }
    # remove anything that resembles a field but did not match a known field name
    result.gsub!(/\{\{\.w+\}\}/, '')
    return result
  end
end
