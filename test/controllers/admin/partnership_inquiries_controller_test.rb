require "test_helper"

class Admin::PartnershipInquiriesControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = User.create!(
      name: "Admin User",
      email: "admin_partnership_#{SecureRandom.hex(4)}@connectingheartsng.org",
      password: "password123",
      role: "admin"
    )
    post admin_login_url, params: { email: @user.email, password: "password123" }

    @partnership_inquiry = PartnershipInquiry.create!(
      organization_name: "Global Hope Foundation",
      contact_person: "Sarah Connor",
      email: "sarah@globalhope.org",
      phone: "08012345678",
      partnership_type: "Educational Institution Partner",
      message: "We want to partner by sponsoring textbooks and counseling sessions for 100 students.",
      status: "pending"
    )
  end

  test "should get index without Message column and with View icon" do
    get admin_partnership_inquiries_url
    assert_response :success
    assert_select "h1", text: /Partnership Proposals/
    assert_select "th", text: "Organization"
    assert_select "th", text: "Contact Person"
    assert_select "th", text: "Type"
    assert_select "th", text: "Email & Phone"
    assert_select "th", text: "Status"
    assert_select "th", text: "Date"
    assert_select "th", text: "Actions"
    # Ensure "Message" is not a column in the table header
    assert_select "thead th", text: /Message/, count: 0
    # Ensure View button/link exists
    assert_select "a[href=?]", admin_partnership_inquiry_path(@partnership_inquiry)
    # Ensure Email button exists with stimulus action
    assert_select "button[data-action*='partnership-email#open']"
  end

  test "should show partnership inquiry details" do
    get admin_partnership_inquiry_url(@partnership_inquiry)
    assert_response :success
    assert_select "h1", text: /Global Hope Foundation/
    assert_select "span", text: /Educational Institution Partner/
    assert_match "sarah@globalhope.org", response.body
    assert_match "We want to partner by sponsoring textbooks", response.body
  end

  test "should update partnership inquiry status" do
    patch admin_partnership_inquiry_url(@partnership_inquiry), params: {
      partnership_inquiry: { status: "partnered" }
    }
    assert_redirected_to admin_partnership_inquiries_path
    @partnership_inquiry.reload
    assert_equal "partnered", @partnership_inquiry.status
  end

  test "should send email to organization contact and update status to contacted" do
    post send_email_admin_partnership_inquiry_url(@partnership_inquiry), params: {
      subject: "Collaboration Next Steps",
      message: "Thank you for your proposal. Let us schedule a virtual call."
    }
    assert_redirected_to admin_partnership_inquiries_path
    assert_not_nil flash[:notice]
    @partnership_inquiry.reload
    assert_equal "contacted", @partnership_inquiry.status
  end

  test "should validate presence of message when sending email" do
    post send_email_admin_partnership_inquiry_url(@partnership_inquiry), params: {
      subject: "Test Subject",
      message: ""
    }
    assert_redirected_to admin_partnership_inquiries_path
    assert_equal "Email message cannot be blank.", flash[:alert]
  end

  test "should destroy partnership inquiry" do
    assert_difference("PartnershipInquiry.count", -1) do
      delete admin_partnership_inquiry_url(@partnership_inquiry)
    end
    assert_redirected_to admin_dashboard_path
  end
end
