class EventRegistration < ApplicationRecord
  belongs_to :event

  validates :full_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :attendance_type, inclusion: { in: %w[in_person virtual] }
  validates :status, inclusion: { in: %w[confirmed cancelled waitlist] }
end
