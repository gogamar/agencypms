class Page < ApplicationRecord
  belongs_to :user
  has_many :blocks, dependent: :destroy
  has_many_attached :images
  has_one_attached :video

  PAGE_TYPES = I18n.t('page_types').freeze

  def self.page_type_options
    PAGE_TYPES
  end
end
