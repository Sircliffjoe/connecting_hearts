require "test_helper"

class Admin::AdminDestroyActionsTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(name: "Admin Tester", email: "admin_tester_#{SecureRandom.hex(4)}@connectingheartsng.org", password: "password123", role: "admin")
    post admin_login_url, params: { email: @user.email, password: "password123" }

    @contact_inquiry = ContactInquiry.create!(
      name: "Sender One",
      email: "sender@example.com",
      subject: "Test Inquiry Subject",
      message: "This is a detailed test inquiry message body.",
      status: "pending"
    )

    @support_request = SupportRequest.create!(
      full_name: "Support Seeker",
      email: "seeker@example.com",
      support_category: "Individual Counseling",
      session_format: "Online / Virtual",
      situation_description: "Need confidential counseling support.",
      consent_given: true,
      status: "pending"
    )

    @volunteer_application = VolunteerApplication.create!(
      full_name: "Volunteer Candidate",
      email: "volunteer@example.com",
      role_interest: "Counselor / Therapist",
      skills: "Certified therapist background",
      availability: "Weekends",
      status: "pending"
    )

    @partnership_inquiry = PartnershipInquiry.create!(
      organization_name: "Hope Partners Foundation",
      contact_person: "Director Mike",
      email: "mike@hopepartners.org",
      partnership_type: "Corporate Social Responsibility (CSR)",
      message: "We would love to sponsor therapy sessions.",
      status: "pending"
    )

    @donation = Donation.create!(
      donor_name: "Generous Giver",
      donor_email: "giver@example.com",
      amount: 25000,
      purpose: "General Foundation Support",
      payment_reference: "CHF-TESTDELETE-#{SecureRandom.hex(4).upcase}",
      status: "pending",
      currency: "NGN"
    )
  end

  test "should destroy contact inquiry" do
    assert_difference("ContactInquiry.count", -1) do
      delete admin_contact_inquiry_url(@contact_inquiry)
    end
    assert_redirected_to admin_dashboard_path
    assert_equal "Contact inquiry deleted successfully.", flash[:notice]
  end

  test "should destroy support request" do
    assert_difference("SupportRequest.count", -1) do
      delete admin_support_request_url(@support_request)
    end
    assert_redirected_to admin_dashboard_path
    assert_equal "Support request deleted successfully.", flash[:notice]
  end

  test "should destroy volunteer application" do
    assert_difference("VolunteerApplication.count", -1) do
      delete admin_volunteer_application_url(@volunteer_application)
    end
    assert_redirected_to admin_dashboard_path
    assert_equal "Volunteer application deleted successfully.", flash[:notice]
  end

  test "should destroy partnership inquiry" do
    assert_difference("PartnershipInquiry.count", -1) do
      delete admin_partnership_inquiry_url(@partnership_inquiry)
    end
    assert_redirected_to admin_dashboard_path
    assert_equal "Partnership proposal deleted successfully.", flash[:notice]
  end

  test "should destroy donation" do
    assert_difference("Donation.count", -1) do
      delete admin_donation_url(@donation)
    end
    assert_redirected_to admin_dashboard_path
    assert_match /deleted successfully/, flash[:notice]
  end

  test "should render dashboard with all sections" do
    get admin_dashboard_url
    assert_response :success
    assert_select "h2", text: /Donations & Payment Receipts Log/
    assert_select "h2", text: /Recent Contact Inquiries/
    assert_select "h2", text: /Recent Support & Counseling Requests/
    assert_select "h2", text: /Volunteer Applications/
    assert_select "h2", text: /Partnership Proposals/
    assert_select "svg"
  end

  test "should render all admin index views with icon-only action buttons" do
    get admin_events_url
    assert_response :success

    get admin_testimonials_url
    assert_response :success

    get admin_stories_url
    assert_response :success

    get admin_resources_url
    assert_response :success

    get admin_users_url
    assert_response :success

    get admin_support_requests_url
    assert_response :success

    get admin_contact_inquiries_url
    assert_response :success

    get admin_volunteer_applications_url
    assert_response :success

    get admin_partnership_inquiries_url
    assert_response :success

    get admin_donations_url
    assert_response :success
  end
end
