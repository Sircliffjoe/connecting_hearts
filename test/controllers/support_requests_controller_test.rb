require "test_helper"

class SupportRequestsControllerTest < ActionDispatch::IntegrationTest
  test "should create support request with valid attributes" do
    assert_difference("SupportRequest.count", 1) do
      post support_requests_url, params: {
        support_request: {
          full_name: "Test User",
          email: "test@example.com",
          phone: "08012345678",
          preferred_contact_method: "WhatsApp",
          support_category: "Individual Counseling",
          session_format: "Online / Virtual",
          situation_description: "This is a detailed description of the situation requiring support.",
          consent_given: "1"
        }
      }
    end

    assert_redirected_to confirmation_support_requests_url
  end

  test "should not create support request without consent" do
    assert_no_difference("SupportRequest.count") do
      post support_requests_url, params: {
        support_request: {
          full_name: "Test User",
          email: "test@example.com",
          support_category: "Individual Counseling",
          situation_description: "Valid situation description text...",
          consent_given: "0"
        }
      }
    end

    assert_response :unprocessable_entity
  end
end
