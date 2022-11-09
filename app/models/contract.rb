class Contract < ApplicationRecord
  belongs_to :realestate
  belongs_to :rstemplate
  belongs_to :buyer
  validates :realestate_id, presence: true
  validates :rstemplate_id, presence: true
  has_many_attached :photos


  def self.parse_template(template, attrs = {})
    result = template
    attrs.each { |field, value| result.gsub!("{{#{field}}}", value) }
    # remove anything that resembles a field but did not match a known field name
    result.gsub!(/\{\{\.w+\}\}/, '')
    return result
  end
end
