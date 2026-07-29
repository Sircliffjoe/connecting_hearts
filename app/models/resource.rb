class Resource < ApplicationRecord
  CATEGORIES = ["Singles", "Marriage", "Communication", "Emotional Wellbeing", "Family & Parenting", "Education"].freeze
  TYPES = ["Article", "Video", "Audio Podcast", "PDF Guide", "FAQ"].freeze

  validates :title, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :resource_type, presence: true, inclusion: { in: TYPES }

  scope :published, -> { where(published: true).order(created_at: :desc) }
  scope :by_category, ->(cat) { cat.present? ? where(category: cat) : all }
  scope :by_type, ->(t) { t.present? ? where(resource_type: t) : all }
end
