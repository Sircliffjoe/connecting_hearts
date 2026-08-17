module Admin
  class PartnershipInquiriesController < ApplicationController
    def index
      @partnership_inquiries = PartnershipInquiry.recent
    end

    def show
      @partnership_inquiry = PartnershipInquiry.find(params[:id])
    end

    def update
      @partnership_inquiry = PartnershipInquiry.find(params[:id])
      if @partnership_inquiry.update(params.require(:partnership_inquiry).permit(:status))
        redirect_back fallback_location: admin_partnership_inquiries_path, notice: "Partnership inquiry status updated successfully."
      else
        redirect_back fallback_location: admin_partnership_inquiries_path, alert: "Failed to update status."
      end
    end

    def destroy
      @partnership_inquiry = PartnershipInquiry.find(params[:id])
      @partnership_inquiry.destroy
      redirect_back fallback_location: admin_dashboard_path, notice: "Partnership proposal deleted successfully."
    end

    def send_email
      @partnership_inquiry = PartnershipInquiry.find(params[:id])
      subject = params[:subject].presence || "Re: Partnership Proposal - #{@partnership_inquiry.organization_name}"
      body = params[:message].presence || params[:body].presence

      if body.blank?
        redirect_back fallback_location: admin_partnership_inquiries_path, alert: "Email message cannot be blank."
        return
      end

      recipient_name = @partnership_inquiry.contact_person.presence || @partnership_inquiry.organization_name

      html_body = <<~HTML
        <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333; line-height: 1.6;">
          <div style="background-color: #3b0764; color: #ffffff; padding: 24px; text-align: center; border-radius: 12px 12px 0 0;">
            <h1 style="margin: 0; font-size: 22px;">Connecting Hearts Foundation</h1>
            <p style="margin: 6px 0 0 0; font-size: 13px; opacity: 0.9;">Partnerships & Collaborations</p>
          </div>
          <div style="background-color: #ffffff; padding: 28px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 12px 12px;">
            <p style="font-size: 15px; font-weight: bold; color: #3b0764; margin-top: 0;">Dear #{ERB::Util.html_escape(recipient_name)},</p>
            <div style="margin: 20px 0; color: #1f2937; white-space: pre-wrap; line-height: 1.6; font-size: 14px;">#{ERB::Util.html_escape(body)}</div>
            <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 24px 0;" />
            <p style="font-size: 12px; color: #6b7280; text-align: center; margin: 0;">
              Connecting Hearts for Singles & Married Foundation<br>
              Delta State, Nigeria
            </p>
          </div>
        </div>
      HTML

      result = BrevoService.send_email(
        to_email: @partnership_inquiry.email,
        to_name: recipient_name,
        subject: subject,
        html_content: html_body,
        text_content: body
      )

      # Mark inquiry as contacted if it was pending
      if @partnership_inquiry.status == "pending"
        @partnership_inquiry.update(status: "contacted")
      end

      if result[:success]
        redirect_back fallback_location: admin_partnership_inquiries_path, notice: "Email successfully sent to #{recipient_name} (#{@partnership_inquiry.email})."
      elsif result[:message] == "BREVO_API_KEY is not configured"
        redirect_back fallback_location: admin_partnership_inquiries_path, notice: "Email simulated / queued for #{@partnership_inquiry.email} (BREVO_API_KEY not configured in local environment)."
      else
        redirect_back fallback_location: admin_partnership_inquiries_path, alert: "Failed to send email: #{result[:error] || result[:message]}"
      end
    end
  end
end
