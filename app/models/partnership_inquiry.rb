class PartnershipInquiry < ApplicationRecord
  TYPES = [
    "Programme Sponsorship",
    "Corporate Social Responsibility (CSR)",
    "Professional Services Support",
    "Media Partnership",
    "Educational Institution Partner",
    "Church / Religious Organization Partner",
    "NGO / Community Partner"
  ].freeze

  STATUSES = ["pending", "contacted", "partnered", "closed"].freeze

  validates :organization_name, presence: true
  validates :contact_person, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :partnership_type, presence: true
  validates :message, presence: true, length: { minimum: 10 }
  validates :status, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }
  scope :recent, -> { order(created_at: :desc) }
end
