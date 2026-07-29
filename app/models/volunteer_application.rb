class VolunteerApplication < ApplicationRecord
  ROLES = [
    "Counselor / Therapist",
    "Media & Communications (Photo/Video)",
    "Content Writer / Copywriter",
    "Graphic Designer / Web Developer",
    "Event Coordinator / Logistics",
    "Administrative Support",
    "General Volunteer"
  ].freeze

  STATUSES = ["pending", "reviewed", "accepted", "declined"].freeze

  validates :full_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role_interest, presence: true
  validates :status, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }
  scope :recent, -> { order(created_at: :desc) }
end
