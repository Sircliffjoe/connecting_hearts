module Admin
  class DonationsController < ApplicationController
    def index
      @donations = Donation.successful
    end
  end
end
