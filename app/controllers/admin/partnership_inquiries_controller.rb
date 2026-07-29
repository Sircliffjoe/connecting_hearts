module Admin
  class PartnershipInquiriesController < ApplicationController
    def index
      @partnership_inquiries = PartnershipInquiry.recent
    end
  end
end
