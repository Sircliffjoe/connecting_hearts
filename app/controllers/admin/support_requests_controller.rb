module Admin
  class SupportRequestsController < ApplicationController
    def index
      @support_requests = SupportRequest.recent
    end

    def show
      @support_request = SupportRequest.find(params[:id])
    end

    def update
      @support_request = SupportRequest.find(params[:id])
      if @support_request.update(support_request_params)
        redirect_to admin_support_request_path(@support_request), notice: "Support request status updated."
      else
        render :show, status: :unprocessable_entity
      end
    end

    private

    def support_request_params
      params.require(:support_request).permit(:status, :notes)
    end
  end
end
