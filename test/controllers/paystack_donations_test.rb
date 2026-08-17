require "test_helper"

class PaystackDonationsTest < ActionDispatch::IntegrationTest
  def with_stubbed_method(klass, method_name, return_value)
    singleton = klass.singleton_class
    orig_method = klass.method(method_name)
    singleton.send(:define_method, method_name) { |*args, **kwargs| return_value }
    yield
  ensure
    singleton.send(:define_method, method_name, orig_method)
  end

  test "should initialize paystack transaction when payment_method is paystack" do
    mock_response = {
      "status" => true,
      "message" => "Authorization URL created",
      "data" => {
        "authorization_url" => "https://checkout.paystack.com/mock-checkout-url",
        "access_code" => "mock_access_code",
        "reference" => "CHF-MOCK123"
      }
    }

    with_stubbed_method(PaymentGateways::PaystackService, :initialize_transaction, mock_response) do
      assert_difference("Donation.count", 1) do
        post donations_url, params: {
          payment_method: "paystack",
          donation: {
            donor_name: "Paystack Donor",
            donor_email: "paystack_donor@example.com",
            amount: 15000,
            purpose: "Sponsor Counseling & Therapy Sessions"
          }
        }
      end

      assert_redirected_to "https://checkout.paystack.com/mock-checkout-url"
      donation = Donation.last
      assert_equal "pending", donation.status
      assert_equal 15000, donation.amount
    end
  end

  test "should handle paystack verification callback on success" do
    donation = Donation.create!(
      donor_name: "Online Donor",
      donor_email: "online@example.com",
      amount: 20000,
      purpose: "General Foundation Support",
      payment_reference: "CHF-VERIFY-123",
      status: "pending",
      currency: "NGN"
    )

    mock_verification = {
      "status" => true,
      "message" => "Verification successful",
      "data" => {
        "status" => "success",
        "reference" => donation.payment_reference,
        "amount" => 2000000,
        "channel" => "card",
        "id" => 987654321
      }
    }

    with_stubbed_method(PaymentGateways::PaystackService, :verify_transaction, mock_verification) do
      get callback_donations_url, params: { reference: donation.payment_reference }

      donation.reload
      assert_equal "successful", donation.status
      assert_match /Paid online via Paystack/, donation.notes
      assert_redirected_to confirmation_donations_path(ref: donation.payment_reference)
      assert_equal "Payment successful! Thank you for your generous donation.", flash[:notice]
    end
  end

  test "should handle initialize_paystack route for existing pending donation" do
    donation = Donation.create!(
      donor_name: "Late Online Payer",
      donor_email: "late@example.com",
      amount: 10000,
      purpose: "General Foundation Support",
      payment_reference: "CHF-LATE-123",
      status: "pending",
      currency: "NGN"
    )

    mock_response = {
      "status" => true,
      "message" => "Authorization URL created",
      "data" => {
        "authorization_url" => "https://checkout.paystack.com/mock-late-url",
        "access_code" => "mock_code",
        "reference" => donation.payment_reference
      }
    }

    with_stubbed_method(PaymentGateways::PaystackService, :initialize_transaction, mock_response) do
      post initialize_paystack_donations_url, params: { payment_reference: donation.payment_reference }
      assert_redirected_to "https://checkout.paystack.com/mock-late-url"
    end
  end

  test "should return json payload for Paystack popup modal when requested via JSON" do
    assert_difference("Donation.count", 1) do
      post donations_url, params: {
        payment_method: "paystack",
        donation: {
          donor_name: "Modal Donor",
          donor_email: "modal_donor@example.com",
          amount: 52000,
          purpose: "General Foundation Support"
        }
      }, as: :json
    end

    assert_response :success
    data = JSON.parse(response.body)
    assert_equal true, data["success"]
    assert_equal 5200000, data["amount_in_kobo"]
    assert_equal "modal_donor@example.com", data["donor_email"]
    assert_equal "Modal Donor", data["donor_name"]
    assert_match /^CHF-/, data["payment_reference"]
    assert_not_nil data["public_key"]
  end
end
