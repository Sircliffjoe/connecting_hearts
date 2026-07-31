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

  test "should block submission when security puzzle is answered incorrectly" do
    assert_no_difference("ContactInquiry.count") do
      post contact_inquiries_url, headers: { "HTTP_REFERER" => contact_url }, params: {
        puzzle_answer: "999",
        puzzle_token: Digest::SHA256.hexdigest("10-secret"),
        contact_inquiry: {
          name: "Bot User",
          email: "bot@example.com",
          subject: "Test",
        }
      }
    end

    assert_redirected_to contact_url
  end

  test "should create contact inquiry when security puzzle is answered correctly" do
    secret = Rails.application.secret_key_base.presence || "connecting-hearts-secret-key"
    expected = 8
    token = Digest::SHA256.hexdigest("#{expected}-#{secret.first(16)}")

    assert_difference("ContactInquiry.count", 1) do
      post contact_inquiries_url, params: {
        puzzle_answer: "8",
        puzzle_token: token,
        contact_inquiry: {
          name: "Ettah Clifford Joe",
          email: "ettah@example.com",
          subject: "Inquiry",
          message: "Valid test inquiry message."
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
