class Story < ApplicationRecord
  CATEGORIES = ["Beneficiary Story", "Volunteer Spotlight", "Conference Impact", "Founder Reflection"].freeze

  validates :title, presence: true
  validates :body, presence: true

  scope :published, -> { where(published: true).order(created_at: :desc) }
  scope :featured, -> { where(featured: true) }
end
