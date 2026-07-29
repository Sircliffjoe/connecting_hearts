require "test_helper"

class ContactInquiriesControllerTest < ActionDispatch::IntegrationTest
  test "should create contact inquiry with valid parameters" do
    assert_difference("ContactInquiry.count", 1) do
      post contact_inquiries_url, params: {
        contact_inquiry: {
          name: "Eloho Sodje",
          email: "eloho@example.com",
          subject: "Inquiry about Experience 4.0",
          message: "I would like to inquire about registering a group for the foundation launch edition."
        }
      }
    end

    assert_redirected_to contact_url
  end

  test "should block submission when honeypot trap is filled by bot" do
    assert_no_difference("ContactInquiry.count") do
      post contact_inquiries_url, headers: { "HTTP_REFERER" => contact_url }, params: {
        website_hp: "bot_filled_value",
        contact_inquiry: {
          name: "Bot User",
          email: "bot@example.com",
          subject: "Spam Offer",
          message: "Automated spam message."
        }
      }
    end

    assert_redirected_to contact_url
  end

  test "should block submission when spam keywords are present" do
    assert_no_difference("ContactInquiry.count") do
      post contact_inquiries_url, headers: { "HTTP_REFERER" => contact_url }, params: {
        contact_inquiry: {
          name: "Spammer",
          email: "spam@example.com",
          subject: "Buy Backlinks Fast",
          message: "Check out our cheap crypto investment and buy backlinks."
        }
      }
    end

    assert_redirected_to contact_url
  end

  test "should fail to create contact inquiry with invalid email" do
    assert_no_difference("ContactInquiry.count") do
      post contact_inquiries_url, params: {
        contact_inquiry: {
          name: "Invalid Email Test",
          email: "invalid-email",
          subject: "Test Subject",
          message: "This is a test message text long enough."
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
