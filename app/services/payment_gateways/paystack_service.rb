require 'net/http'
require 'json'

module PaymentGateways
  class PaystackService
    PAYSTACK_SECRET_KEY = ENV.fetch('PAYSTACK_SECRET_KEY', 'sk_test_mock_paystack_key')
    BASE_URL = 'https://api.paystack.co'

    def self.initialize_transaction(email:, amount_in_kobo:, reference:, callback_url:, metadata: {})
      uri = URI("#{BASE_URL}/transaction/initialize")
      req = Net::HTTP::Post.new(uri)
      req['Authorization'] = "Bearer #{PAYSTACK_SECRET_KEY}"
      req['Content-Type'] = 'application/json'
      req.body = {
        email: email,
        amount: amount_in_kobo,
        reference: reference,
        callback_url: callback_url,
        metadata: metadata
      }.to_json

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      JSON.parse(res.body)
    rescue => e
      Rails.logger.error("Paystack Initialization Error: #{e.message}")
      { 'status' => false, 'message' => e.message }
    end

    def self.verify_transaction(reference)
      uri = URI("#{BASE_URL}/transaction/verify/#{reference}")
      req = Net::HTTP::Get.new(uri)
      req['Authorization'] = "Bearer #{PAYSTACK_SECRET_KEY}"

      res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
        http.request(req)
      end

      JSON.parse(res.body)
    rescue => e
      Rails.logger.error("Paystack Verification Error: #{e.message}")
      { 'status' => false, 'message' => e.message }
    end
  end
end
