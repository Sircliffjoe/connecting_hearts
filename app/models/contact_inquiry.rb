class ContactInquiry < ApplicationRecord
  STATUSES = ["pending", "reviewed", "replied", "archived"].freeze

  validates :name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :subject, presence: true, length: { minimum: 3 }
  validates :message, presence: true, length: { minimum: 10 }
  validates :status, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }
  scope :recent, -> { order(created_at: :desc) }
end
