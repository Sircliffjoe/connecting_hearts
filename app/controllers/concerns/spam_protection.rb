module SpamProtection
  extend ActiveSupport::Concern

  SPAM_KEYWORDS = [
    /crypto\s*investment/i,
    /buy\s*backlinks/i,
    /seo\s*ranking\s*guarantee/i,
    /casino\s*bonus/i,
    /viagra/i,
    /bit\.ly/i,
    /t\.co/i,
    /telegram\s*channel/i
  ].freeze

  included do
    helper_method :generate_security_puzzle if respond_to?(:helper_method)
  end

  def generate_security_puzzle
    num1 = rand(2..9)
    num2 = rand(1..9)
    expected = num1 + num2
    secret = Rails.application.secret_key_base.presence || "connecting-hearts-secret-key"
    token = Digest::SHA256.hexdigest("#{expected}-#{secret.first(16)}")
    { num1: num1, num2: num2, token: token }
  end

  protected

  # Primary protection method to call before creating submissions
  def verify_spam_and_rate_limit!(text_content: "", max_requests: 5, window: 10.minutes)
    if is_honeypot_filled?
      Rails.logger.warn("[SPAM BLOCKED] Honeypot triggered from IP: #{request.remote_ip}")
      handle_spam_detected("Form submission rejected.")
      return false
    end

    if is_submitted_too_fast?
      Rails.logger.warn("[SPAM BLOCKED] Fast automated submission (< 2s) from IP: #{request.remote_ip}")
      handle_spam_detected("Form submission was too fast. Please take your time.")
      return false
    end

    if is_rate_limited?(max_requests: max_requests, window: window)
      Rails.logger.warn("[SPAM BLOCKED] Rate limit exceeded from IP: #{request.remote_ip}")
      handle_rate_limit_exceeded
      return false
    end

    if params[:puzzle_token].present? && !is_puzzle_valid?
      Rails.logger.warn("[SPAM BLOCKED] Security puzzle solution incorrect from IP: #{request.remote_ip}")
      handle_spam_detected("Security puzzle answer was incorrect. Please solve the puzzle correctly before submitting.")
      return false
    end

    if is_spam_keyword_present?(text_content)
      Rails.logger.warn("[SPAM BLOCKED] Spam keyword detected from IP: #{request.remote_ip}")
      handle_spam_detected("Submission contained unallowed promotional content.")
      return false
    end

    true
  end

  private

  def is_puzzle_valid?
    ans = params[:puzzle_answer].to_s.strip
    token = params[:puzzle_token].to_s.strip
    return false if ans.blank? || token.blank?

    secret = Rails.application.secret_key_base.presence || "connecting-hearts-secret-key"
    expected_hash = Digest::SHA256.hexdigest("#{ans}-#{secret.first(16)}")
    ActiveSupport::SecurityUtils.secure_compare(expected_hash, token)
  end

  def is_honeypot_filled?
    hp = params[:website_hp] || params[:hp_field] || (params.values.find { |v| v.is_a?(Hash) && v[:website_hp].present? })
    hp.present?
  end

  def is_submitted_too_fast?
    timestamp = params[:form_timestamp].to_i
    return false if timestamp.zero? # Gracefully allow if timestamp not present

    elapsed = Time.current.to_i - timestamp
    elapsed < 2 # Less than 2 seconds is considered bot automation
  end

  def is_rate_limited?(max_requests:, window:)
    cache_key = "rate_limit:#{request.remote_ip}:#{controller_name}"
    current_count = Rails.cache.read(cache_key) || 0

    if current_count >= max_requests
      true
    else
      Rails.cache.write(cache_key, current_count + 1, expires_in: window)
      false
    end
  end

  def is_spam_keyword_present?(text)
    return false if text.blank?
    SPAM_KEYWORDS.any? { |pattern| pattern.match?(text.to_s) }
  end

  def handle_spam_detected(message)
    flash[:error] = message
    redirect_to request.referrer || root_path
  end

  def handle_rate_limit_exceeded
    flash[:error] = "Too many submissions from your location. Please wait a few minutes before trying again."
    redirect_to request.referrer || root_path
  end
end
