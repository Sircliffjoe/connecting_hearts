require "net/http"
require "json"
require "uri"

class BrevoService
  API_URL = "https://api.brevo.com/v3/smtp/email".freeze

  def self.api_key
    ENV["BREVO_API_KEY"].presence
  end

  def self.default_sender
    {
      "name" => ENV.fetch("BREVO_SENDER_NAME", "Connecting Hearts Foundation"),
      "email" => ENV.fetch("BREVO_SENDER_EMAIL", "info@connectingheartsfoundation.org")
    }
  end

  # Generic transactional email dispatch
  def self.send_email(to_email:, to_name: nil, subject:, html_content:, text_content: nil, reply_to: nil, sender: nil)
    key = api_key
    unless key.present?
      Rails.logger.warn("[BrevoService] BREVO_API_KEY not configured. Email not sent to #{to_email}.")
      return { success: false, message: "BREVO_API_KEY is not configured" }
    end

    sender_payload = sender || default_sender
    recipient_payload = { "email" => to_email }
    recipient_payload["name"] = to_name if to_name.present?

    payload = {
      "sender" => sender_payload,
      "to" => [recipient_payload],
      "subject" => subject,
      "htmlContent" => html_content
    }
    payload["textContent"] = text_content if text_content.present?
    payload["replyTo"] = { "email" => reply_to } if reply_to.present?

    uri = URI(API_URL)
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = 10
    http.open_timeout = 5

    request = Net::HTTP::Post.new(uri.path, {
      "api-key" => key,
      "Content-Type" => "application/json",
      "Accept" => "application/json"
    })
    request.body = payload.to_json

    response = http.request(request)

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body) rescue {}
      message_id = data["messageId"]
      Rails.logger.info("[BrevoService] Transactional email sent to #{to_email}. MessageId: #{message_id}")
      { success: true, message_id: message_id, data: data }
    else
      Rails.logger.error("[BrevoService] Failed to send email to #{to_email}. HTTP #{response.code}: #{response.body}")
      { success: false, code: response.code, error: response.body }
    end
  rescue => e
    Rails.logger.error("[BrevoService] Exception while sending email to #{to_email}: #{e.message}")
    { success: false, error: e.message }
  end

  # Helper: Send acknowledgement for Contact Inquiries
  def self.send_contact_inquiry_confirmation(inquiry)
    html = <<~HTML
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333; line-height: 1.6;">
        <div style="background-color: #3b0764; color: #ffffff; padding: 24px; text-align: center; border-radius: 12px 12px 0 0;">
          <h1 style="margin: 0; font-size: 24px;">Connecting Hearts Foundation</h1>
          <p style="margin: 6px 0 0 0; font-size: 14px; opacity: 0.9;">Safe Spaces • Counseling • Child Educational Support</p>
        </div>
        <div style="background-color: #ffffff; padding: 28px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 12px 12px;">
          <h2 style="color: #3b0764; font-size: 20px; margin-top: 0;">Thank you for contacting us, #{ERB::Util.html_escape(inquiry.name)}</h2>
          <p>We have received your message regarding: <strong>"#{ERB::Util.html_escape(inquiry.subject)}"</strong>.</p>
          <div style="background-color: #f9fafb; border-left: 4px solid #9333ea; padding: 14px; margin: 20px 0; border-radius: 4px;">
            <p style="margin: 0; font-style: italic; color: #4b5563;">"#{ERB::Util.html_escape(inquiry.message)}"</p>
          </div>
          <p>Our team will review your inquiry and get back to you shortly.</p>
          <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 24px 0;" />
          <p style="font-size: 12px; color: #6b7280; text-align: center; margin: 0;">
            Connecting Hearts for Singles & Married Foundation<br>
            Delta State, Nigeria
          </p>
        </div>
      </div>
    HTML

    send_email(
      to_email: inquiry.email,
      to_name: inquiry.name,
      subject: "We received your message: #{inquiry.subject}",
      html_content: html,
      text_content: "Hello #{inquiry.name},\n\nThank you for reaching out. We have received your inquiry: \"#{inquiry.subject}\". Our team will respond shortly.\n\nConnecting Hearts Foundation"
    )
  end

  # Helper: Send donation receipt / confirmation
  def self.send_donation_receipt(donation)
    html = <<~HTML
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333; line-height: 1.6;">
        <div style="background-color: #064e3b; color: #ffffff; padding: 24px; text-align: center; border-radius: 12px 12px 0 0;">
          <h1 style="margin: 0; font-size: 24px;">Donation Receipt & Confirmation</h1>
          <p style="margin: 6px 0 0 0; font-size: 14px; opacity: 0.9;">Connecting Hearts for Singles & Married Foundation</p>
        </div>
        <div style="background-color: #ffffff; padding: 28px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 12px 12px;">
          <h2 style="color: #064e3b; font-size: 20px; margin-top: 0;">Thank You for Your Generous Support!</h2>
          <p>Dear #{ERB::Util.html_escape(donation.donor_name.presence || 'Valued Supporter')},</p>
          <p>We gratefully acknowledge receipt of your donation to support the mission of Connecting Hearts Foundation.</p>
          
          <table style="width: 100%; border-collapse: collapse; margin: 20px 0; background-color: #f9fafb; border-radius: 8px; overflow: hidden;">
            <tr style="border-bottom: 1px solid #e5e7eb;">
              <td style="padding: 12px; font-weight: bold; color: #4b5563;">Payment Reference</td>
              <td style="padding: 12px; font-family: monospace; font-weight: bold; color: #3b0764;">#{ERB::Util.html_escape(donation.payment_reference)}</td>
            </tr>
            <tr style="border-bottom: 1px solid #e5e7eb;">
              <td style="padding: 12px; font-weight: bold; color: #4b5563;">Amount</td>
              <td style="padding: 12px; font-size: 18px; font-weight: bold; color: #065f46;">₦#{ERB::Util.html_escape(ActiveSupport::NumberHelper.number_to_delimited(donation.amount))}</td>
            </tr>
            <tr style="border-bottom: 1px solid #e5e7eb;">
              <td style="padding: 12px; font-weight: bold; color: #4b5563;">Purpose</td>
              <td style="padding: 12px; color: #1f2937;">#{ERB::Util.html_escape(donation.purpose)}</td>
            </tr>
            <tr>
              <td style="padding: 12px; font-weight: bold; color: #4b5563;">Status</td>
              <td style="padding: 12px; font-weight: bold; color: #065f46;">#{ERB::Util.html_escape(donation.status_display_name)}</td>
            </tr>
          </table>

          <p>Your financial partnership directly funds confidential therapy sessions and keeps vulnerable children in school.</p>
          
          <hr style="border: none; border-top: 1px solid #e5e7eb; margin: 24px 0;" />
          <p style="font-size: 12px; color: #6b7280; text-align: center; margin: 0;">
            Connecting Hearts for Singles & Married Foundation<br>
            Delta State, Nigeria
          </p>
        </div>
      </div>
    HTML

    send_email(
      to_email: donation.donor_email,
      to_name: donation.donor_name,
      subject: "Donation Receipt [#{donation.payment_reference}] - Connecting Hearts Foundation",
      html_content: html,
      text_content: "Thank you for your donation of ₦#{ActiveSupport::NumberHelper.number_to_delimited(donation.amount)} (#{donation.payment_reference}) for #{donation.purpose}.\n\nConnecting Hearts Foundation"
    )
  end

  # Helper: Send support request confirmation
  def self.send_support_request_confirmation(request)
    html = <<~HTML
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333; line-height: 1.6;">
        <div style="background-color: #4c0519; color: #ffffff; padding: 24px; text-align: center; border-radius: 12px 12px 0 0;">
          <h1 style="margin: 0; font-size: 22px;">Connecting Hearts Foundation</h1>
          <p style="margin: 6px 0 0 0; font-size: 13px; opacity: 0.9;">Confidential Support & Counseling Intake</p>
        </div>
        <div style="background-color: #ffffff; padding: 28px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 12px 12px;">
          <h2 style="color: #4c0519; font-size: 18px; margin-top: 0;">Support Request Received</h2>
          <p>Hello #{ERB::Util.html_escape(request.full_name)},</p>
          <p>We have safely received your confidential request for <strong>#{ERB::Util.html_escape(request.support_category)}</strong> (#{ERB::Util.html_escape(request.session_format)}).</p>
          <p>Our counseling intake team is reviewing your details with strict confidentiality. A support coordinator will contact you via your preferred method (#{ERB::Util.html_escape(request.preferred_contact_method)}) shortly.</p>
          <p style="font-size: 13px; color: #4b5563; background: #fff1f2; padding: 12px; border-radius: 6px;">
            🔒 <em>Safeguarding Notice: All information shared is treated with the highest degree of privacy and discretion.</em>
          </p>
        </div>
      </div>
    HTML

    send_email(
      to_email: request.email,
      to_name: request.full_name,
      subject: "Support Request Received - Connecting Hearts Foundation",
      html_content: html,
      text_content: "Hello #{request.full_name},\n\nWe have safely received your confidential request for #{request.support_category}. Our support team will contact you shortly.\n\nConnecting Hearts Foundation"
    )
  end

  # Helper: Send volunteer application confirmation
  def self.send_volunteer_confirmation(app)
    html = <<~HTML
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333; line-height: 1.6;">
        <div style="background-color: #581c87; color: #ffffff; padding: 24px; text-align: center; border-radius: 12px 12px 0 0;">
          <h1 style="margin: 0; font-size: 22px;">Connecting Hearts Foundation</h1>
          <p style="margin: 6px 0 0 0; font-size: 13px; opacity: 0.9;">Volunteer Community</p>
        </div>
        <div style="background-color: #ffffff; padding: 28px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 12px 12px;">
          <h2 style="color: #581c87; font-size: 18px; margin-top: 0;">Volunteer Application Received</h2>
          <p>Hello #{ERB::Util.html_escape(app.full_name)},</p>
          <p>Thank you for offering your time and talents to support our mission as <strong>#{ERB::Util.html_escape(app.role_interest)}</strong>.</p>
          <p>Our volunteer coordination team will review your application and contact you with the next onboarding steps.</p>
        </div>
      </div>
    HTML

    send_email(
      to_email: app.email,
      to_name: app.full_name,
      subject: "Volunteer Application Received - Connecting Hearts Foundation",
      html_content: html,
      text_content: "Hello #{app.full_name},\n\nThank you for applying to volunteer as #{app.role_interest}. Our team will review your application and get in touch.\n\nConnecting Hearts Foundation"
    )
  end

  # Helper: Send partnership inquiry confirmation
  def self.send_partnership_confirmation(inquiry)
    html = <<~HTML
      <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; color: #333; line-height: 1.6;">
        <div style="background-color: #3b0764; color: #ffffff; padding: 24px; text-align: center; border-radius: 12px 12px 0 0;">
          <h1 style="margin: 0; font-size: 22px;">Connecting Hearts Foundation</h1>
          <p style="margin: 6px 0 0 0; font-size: 13px; opacity: 0.9;">Partnerships & Collaborations</p>
        </div>
        <div style="background-color: #ffffff; padding: 28px; border: 1px solid #e5e7eb; border-top: none; border-radius: 0 0 12px 12px;">
          <h2 style="color: #3b0764; font-size: 18px; margin-top: 0;">Partnership Proposal Received</h2>
          <p>Hello #{ERB::Util.html_escape(inquiry.contact_person)},</p>
          <p>Thank you for reaching out on behalf of <strong>#{ERB::Util.html_escape(inquiry.organization_name)}</strong> regarding a <strong>#{ERB::Util.html_escape(inquiry.partnership_type)}</strong> partnership.</p>
          <p>Our partnership relations team will evaluate your proposal and reach out to schedule an introductory discussion.</p>
        </div>
      </div>
    HTML

    send_email(
      to_email: inquiry.email,
      to_name: inquiry.contact_person,
      subject: "Partnership Proposal Received - Connecting Hearts Foundation",
      html_content: html,
      text_content: "Hello #{inquiry.contact_person},\n\nThank you for reaching out on behalf of #{inquiry.organization_name}. Our team will evaluate your proposal and be in touch.\n\nConnecting Hearts Foundation"
    )
  end
end
