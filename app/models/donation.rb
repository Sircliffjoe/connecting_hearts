class Donation < ApplicationRecord
  PURPOSES = [
    "General Foundation Support",
    "Sponsor Counseling & Therapy Sessions",
    "Support a Child's Education",
    "Support Connecting Hearts Experience Conference"
  ].freeze

  STATUSES = ["pending", "successful", "failed"].freeze

  validates :donor_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :purpose, presence: true
  validates :payment_reference, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  scope :successful, -> { where(status: "successful").order(created_at: :desc) }
end
