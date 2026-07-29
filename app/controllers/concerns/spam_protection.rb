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
    helper_method :spam_protection_fields if respond_to?(:helper_method)
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

    if is_spam_keyword_present?(text_content)
      Rails.logger.warn("[SPAM BLOCKED] Spam keyword detected from IP: #{request.remote_ip}")
      handle_spam_detected("Submission contained unallowed promotional content.")
      return false
    end

    true
  end

  private

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
