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

  def self.parse_template(template, attrs = {})
    result = template
    attrs.each { |field, value| result.gsub!("{{#{field}}}", value) }
    # remove anything that resembles a field but did not match a known field name
    result.gsub!(/\{\{\.w+\}\}/, '')
    return result
  end

  def extract_annexes
    annexes = []
    annexes << registry_addendum.name
    annexes << habitability_addendum.name
    annexes << energy_addendum.name
    addendums_array = addendums.map {|addendum| addendum.filename.to_s.chop.chop.chop.chop}
    annexes << addendums_array
    annexes.flatten
    annexes.flatten.each_with_index.map do |annex, index|
      annex.class
      if annex.include? "addendum"
        "<p>#{I18n.t("#{annex}")} (Annex #{index + 1})</p>"
      else
        "<p>#{annex} (Annex #{index + 1})</p>"
      end
    end
  end
end
