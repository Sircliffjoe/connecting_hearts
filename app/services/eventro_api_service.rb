require "net/http"
require "json"

class EventroApiService
  API_URL = "https://api.eventro.africa/v1/events"

  def self.fetch_events(params = {})
    # Attempt to fetch live events from Eventro API (eventro.africa)
    uri = URI(API_URL)
    uri.query = URI.encode_www_form(params) if params.present?

    response = Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == "https", open_timeout: 2, read_timeout: 3) do |http|
      request = Net::HTTP::Get.new(uri)
      request["Accept"] = "application/json"
      request["User-Agent"] = "ConnectingHeartsFoundation/1.0"
      http.request(request)
    end

    if response.is_a?(Net::HTTPSuccess)
      data = JSON.parse(response.body)
      format_api_events(data["data"] || data)
    else
      fallback_events(params)
    end
  rescue StandardError => e
    Rails.logger.warn("Eventro API notice (using local event dataset): #{e.message}")
    fallback_events(params)
  end

  private

  def self.fallback_events(params)
    all_events = [
      {
        id: "evt-40",
        title: "Connecting Hearts Experience 4.0 & Grand Launch",
        theme: "The Conversation Continues. The Mission Begins.",
        edition_number: "4.0",
        event_date: DateTime.parse("2026-08-01 10:00:00 +0100"),
        location: "Grand Event Centre, Warri, Delta State",
        event_type: "Conference & Launch",
        capacity: 500,
        description: "Official launch edition of the Connecting Hearts Foundation featuring keynotes, breakout debates, free therapy consultations, and academic scholarship unveilings.",
        image_url: ActionController::Base.helpers.image_path("pic116.jpeg"),
        featured: true,
        api_source: "eventro.africa"
      },
      {
        id: "evt-30",
        title: "Connecting Hearts Experience 3.0",
        theme: "Love, Sex & Money",
        edition_number: "3.0",
        event_date: DateTime.parse("2026-03-21 10:00:00 +0100"),
        location: "Warri, Delta State",
        event_type: "Conference",
        capacity: 220,
        description: "Unpacking financial compatibility, emotional transparency, and sexual health in modern relationships.",
        image_url: ActionController::Base.helpers.image_path("pic115b.jpeg"),
        featured: false,
        api_source: "eventro.africa"
      },
      {
        id: "evt-w1",
        title: "Couples Communication & Financial Alignment Workshop",
        theme: "Money & Intimacy in Marriage",
        edition_number: "Workshop",
        event_date: DateTime.parse("2026-09-12 14:00:00 +0100"),
        location: "Online / Virtual Stream",
        event_type: "Workshop",
        capacity: 300,
        description: "Virtual masterclass designed for married couples navigating financial pressure and conflict resolution.",
        image_url: ActionController::Base.helpers.image_path("pic117.jpeg"),
        featured: false,
        api_source: "eventro.africa"
      },
      {
        id: "evt-20",
        title: "Connecting Hearts Experience 2.0",
        theme: "Loving You",
        edition_number: "2.0",
        event_date: DateTime.parse("2025-10-18 10:00:00 +0100"),
        location: "Warri, Delta State",
        event_type: "Conference",
        capacity: 180,
        description: "Deep dive into self-worth, emotional intelligence, and building healthy boundaries before and during marriage.",
        image_url: ActionController::Base.helpers.image_path("pic114.jpeg"),
        featured: false,
        api_source: "eventro.africa"
      },
      {
        id: "evt-10",
        title: "Connecting Hearts Experience 1.0",
        theme: "This Thing Called Love",
        edition_number: "1.0",
        event_date: DateTime.parse("2025-07-05 10:00:00 +0100"),
        location: "Warri, Delta State",
        event_type: "Conference",
        capacity: 150,
        description: "Inaugural gathering in Warri bringing together over 100 singles and married individuals for open conversation.",
        image_url: ActionController::Base.helpers.image_path("pic113.jpeg"),
        featured: false,
        api_source: "eventro.africa"
      }
    ]

    # Filter logic
    filtered = all_events.dup

    if params[:date] == "upcoming"
      filtered.select! { |e| e[:event_date] >= Time.current }
    elsif params[:date] == "past"
      filtered.select! { |e| e[:event_date] < Time.current }
    end

    if params[:location].present? && params[:location] != "all"
      loc = params[:location].downcase
      filtered.select! { |e| e[:location].downcase.include?(loc) }
    end

    if params[:event_type].present? && params[:event_type] != "all"
      type = params[:event_type].downcase
      filtered.select! { |e| e[:event_type].downcase.include?(type) }
    end

    filtered
  end

  def self.format_api_events(raw_events)
    Array(raw_events).map do |e|
      {
        id: e["id"],
        title: e["title"],
        theme: e["theme"] || e["summary"],
        edition_number: e["edition_number"] || "Special",
        event_date: DateTime.parse(e["start_date"] || e["event_date"]),
        location: e["location"] || "Warri, Delta State",
        event_type: e["event_type"] || "Conference",
        capacity: e["capacity"] || 200,
        description: e["description"],
        image_url: e["image_url"] || ActionController::Base.helpers.image_path("pic116.jpeg"),
        featured: e["featured"] || false,
        api_source: "eventro.africa"
      }
    end
  end
end
