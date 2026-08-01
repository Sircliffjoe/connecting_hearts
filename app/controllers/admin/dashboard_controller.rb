module Admin
  class DashboardController < ApplicationController
    def index
      @pending_support_count = SupportRequest.pending.count
      @pending_volunteer_count = VolunteerApplication.pending.count
      @pending_partnership_count = PartnershipInquiry.pending.count
      @pending_contact_count = ContactInquiry.pending.count
      @total_donations_count = Donation.count
      @pending_receipts_count = Donation.pending_verification.count
      @total_donations_amount = Donation.successful.sum(:amount)

      @recent_contact_inquiries = ContactInquiry.recent.limit(5)
      @recent_support_requests = SupportRequest.recent.limit(5)
      @recent_partnerships = PartnershipInquiry.recent.limit(5)
      @recent_donations = Donation.recent.limit(5)
    end
  end
end
