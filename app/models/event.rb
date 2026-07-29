class Event < ApplicationRecord
  has_many :event_registrations, dependent: :destroy

  validates :title, presence: true
  validates :event_date, presence: true

  scope :upcoming, -> { where("event_date >= ?", Time.current).order(event_date: :asc) }
  scope :past, -> { where("event_date < ?", Time.current).order(event_date: :desc) }
  scope :featured, -> { where(featured: true) }
end
