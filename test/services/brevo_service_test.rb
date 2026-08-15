require "test_helper"

class BrevoServiceTest < ActiveSupport::TestCase
  test "default sender is configured" do
    sender = BrevoService.default_sender
    assert_not_nil sender["email"]
    assert_not_nil sender["name"]
  end

  test "send_email handles missing api key gracefully" do
    # Temporarily clear key
    original_key = ENV["BREVO_API_KEY"]
    ENV["BREVO_API_KEY"] = nil

    result = BrevoService.send_email(
      to_email: "test@example.com",
      to_name: "Tester",
      subject: "Hello",
      html_content: "<p>Hello</p>"
    )

    assert_equal false, result[:success]
    assert_match /not configured/, result[:message]
  ensure
    ENV["BREVO_API_KEY"] = original_key
  end

  test "send_contact_inquiry_confirmation builds valid html" do
    inquiry = ContactInquiry.new(
      name: "John Contact",
      email: "john@example.com",
      subject: "Conference Details",
      message: "Can I bring a group of 10 people?",
      status: "pending"
    )

    assert_nothing_raised do
      BrevoService.send_contact_inquiry_confirmation(inquiry)
    end
  end

  test "send_donation_receipt builds valid html" do
    donation = Donation.new(
      donor_name: "Kind Supporter",
      donor_email: "kind@example.com",
      amount: 10000,
      purpose: "Support a Child's Education",
      payment_reference: "CHF-TESTBREVO",
      status: "successful",
      currency: "NGN"
    )

    assert_nothing_raised do
      BrevoService.send_donation_receipt(donation)
    end
  end
end
