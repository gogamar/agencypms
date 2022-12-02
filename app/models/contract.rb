class Contract < ApplicationRecord
  belongs_to :realestate
  belongs_to :rstemplate
  belongs_to :buyer
  validates :realestate_id, presence: true
  validates :rstemplate_id, presence: true
  has_many_attached :photos
  has_many_attached :addendums
  has_one_attached :registry_addendum
  has_one_attached :habitability_addendum
  has_one_attached :energy_addendum
  has_one_attached :equipment_addendum

  def self.parse_template(template, attrs = {})
    result = template
    attrs.each { |field, value| result.gsub!("{{#{field}}}", value) }
    # remove anything that resembles a field but did not match a known field name
    result.gsub!(/\{\{\.w+\}\}/, '')
    return result
  end

  def extract_annexos
    annexos = []
    annexos << registry_addendum.name if registry_addendum.attached?
    annexos << habitability_addendum.name if habitability_addendum.attached?
    annexos << energy_addendum.name if energy_addendum.attached?
    annexos << equipment_addendum.name if equipment_addendum.attached?
    addendums_array = addendums.map {|addendum| addendum.filename.to_s.chop.chop.chop.chop} if addendums.attached?
    annexos << addendums_array if addendums.attached?
    annexos.flatten
    annexos.flatten.each_with_index.map do |annex, index|
      annex.class
      if annex.include? "addendum"
        "<p>#{I18n.t("#{annex}")} (Annex #{index + 1})</p>"
      else
        "<p>#{annex} (Annex #{index + 1})</p>"
      end
    end
  end
end
