class Donation < ApplicationRecord
  PURPOSES = [
    "General Foundation Support",
    "Sponsor Counseling & Therapy Sessions",
    "Support a Child's Education",
    "Support Connecting Hearts Experience Conference"
  ].freeze

  STATUSES = ["pending", "receipt_uploaded", "successful", "failed"].freeze

  validates :donor_email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :amount, presence: true, numericality: { greater_than_or_equal_to: 5000, message: "must be at least ₦5,000" }
  validates :purpose, presence: true
  validates :payment_reference, presence: true, uniqueness: true
  validates :status, inclusion: { in: STATUSES }

  scope :recent, -> { order(created_at: :desc) }
  scope :successful, -> { where(status: "successful").order(created_at: :desc) }
  scope :pending_verification, -> { where(status: "receipt_uploaded").order(created_at: :desc) }
  scope :awaiting_payment, -> { where(status: "pending").order(created_at: :desc) }

  def status_badge_class
    case status
    when "successful"
      "bg-emerald-950 text-emerald-300 border border-emerald-800"
    when "receipt_uploaded"
      "bg-amber-950 text-amber-300 border border-amber-800 animate-pulse"
    when "failed"
      "bg-rose-950 text-rose-300 border border-rose-800"
    else
      "bg-slate-800 text-slate-300 border border-slate-700"
    end
  end

  def status_display_name
    case status
    when "successful"
      "Verified / Successful"
    when "receipt_uploaded"
      "Receipt Uploaded (Pending Admin Verification)"
    when "failed"
      "Payment Failed / Invalid"
    else
      "Awaiting Payment"
    end
  end
end

