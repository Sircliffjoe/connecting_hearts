class SupportRequest < ApplicationRecord
  belongs_to :reviewed_by, class_name: "User", optional: true

  CATEGORIES = [
    "Individual Counseling",
    "Couples Counseling",
    "Divorce & Separation Support",
    "Emotional & Mental Wellbeing",
    "Family & Parenting Support",
    "Educational Support for Children",
    "Other Support"
  ].freeze

  FORMATS = ["Online / Virtual", "In-Person (Warri)", "Phone Call"].freeze
  STATUSES = ["pending", "reviewed", "referred", "completed", "archived"].freeze

  validates :full_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :support_category, presence: true
  validates :situation_description, presence: true, length: { minimum: 10 }
  validates :consent_given, acceptance: { accept: true, message: "must be accepted to request support" }
  validates :status, inclusion: { in: STATUSES }

  scope :pending, -> { where(status: "pending") }
  scope :recent, -> { order(created_at: :desc) }
end
