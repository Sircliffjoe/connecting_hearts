class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true
  validates :email, presence: true, uniqueness: { case_sensitive: false }, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :role, presence: true, inclusion: { in: %w[admin super_admin counselor] }

  has_many :reviewed_support_requests, class_name: "SupportRequest", foreign_key: "reviewed_by_id", dependent: :nullify
end

