class ExperiencesController < ApplicationController
  def index
    # Fetch events from Eventro API (eventro.africa) with filter parameters
    @events = EventroApiService.fetch_events(
      date: params[:date],
      location: params[:location],
      event_type: params[:event_type]
    )

    @featured_event = @events.find { |e| e[:featured] } || @events.first
    @past_events = @events.select { |e| e[:event_date] < Time.current }
    @upcoming_events = @events.select { |e| e[:event_date] >= Time.current }

    @testimonials = Testimonial.approved
  end

  def show
    events = EventroApiService.fetch_events
    @event = events.find { |e| e[:id].to_s == params[:id].to_s } || events.first
  end
end
