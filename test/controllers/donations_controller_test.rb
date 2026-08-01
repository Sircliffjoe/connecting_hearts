require "test_helper"

class DonationsControllerTest < ActionDispatch::IntegrationTest
  test "should get new donation page" do
    get new_donation_url
    assert_response :success
    assert_select "h1", "Support The Foundation"
    assert_select "input[value='Donate Now']"
  end

  test "should create donation and redirect to confirmation" do
    assert_difference("Donation.count", 1) do
      post donations_url, params: {
        donation: {
          donor_name: "Jane Doe",
          donor_email: "jane@example.com",
          amount: 10000,
          purpose: "Support a Child's Education"
        }
      }
    end

    donation = Donation.last
    assert_equal "pending", donation.status
    assert_equal "NGN", donation.currency
    assert_equal 10000, donation.amount
    assert_redirected_to confirmation_donations_path(ref: donation.payment_reference)
  end

  test "should reject donation under N5,000" do
    assert_no_difference("Donation.count") do
      post donations_url, params: {
        donation: {
          donor_name: "Jane Doe",
          donor_email: "jane@example.com",
          amount: 2000,
          purpose: "General Foundation Support"
        }
      }
    end

    assert_response :unprocessable_entity
  end

  test "should upload payment receipt" do
    donation = Donation.create!(
      donor_name: "John Smith",
      donor_email: "john@example.com",
      amount: 15000,
      purpose: "General Foundation Support",
      payment_reference: "CHF-TESTREF123",
      status: "pending",
      currency: "NGN"
    )

    file = fixture_file_upload("test/fixtures/files/receipt_sample.png", "image/png") rescue nil

    if file.nil?
      # Create dummy temp file if fixture is missing
      temp_file = Tempfile.new(["receipt", ".png"])
      temp_file.write("dummy image content")
      temp_file.rewind
      file = Rack::Test::UploadedFile.new(temp_file.path, "image/png")
    end

    post upload_receipt_donations_url, params: {
      payment_reference: donation.payment_reference,
      receipt_file: file,
      depositor_name: "John Smith Transfer",
      notes: "Transferred via PremiumTrust Bank app"
    }

    donation.reload
    assert_equal "receipt_uploaded", donation.status
    assert_equal "John Smith Transfer", donation.depositor_name
    assert_match /\/uploads\/receipts\//, donation.receipt_url
    assert_redirected_to confirmation_donations_path(ref: donation.payment_reference)
  end
end
