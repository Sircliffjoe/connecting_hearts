class ExperiencesController < ApplicationController
  include SpamProtection

  def index
    # Fetch events from Eventro API (eventro.africa) combined with local database events
    @events = EventroApiService.fetch_events(
      date: params[:date],
      location: params[:location],
      event_type: params[:event_type]
    )

    @featured_event = @events.find { |e| e[:featured] } || @events.first
    @past_events = @events.select { |e| e[:event_date] < Time.current }
    @upcoming_events = @events.select { |e| e[:event_date] >= Time.current }

    @testimonials = Testimonial.approved.order(created_at: :desc).limit(6)
  end

  def show
    events = EventroApiService.fetch_events
    @event = events.find { |e| e[:id].to_s == params[:id].to_s } || events.find { |e| e[:title].parameterize == params[:id].to_s } || events.first
    @related_events = events.reject { |e| e[:id].to_s == @event[:id].to_s }.first(3)
    @testimonials = Testimonial.approved.limit(3)
  end

  def create_testimonial
    return unless verify_spam_and_rate_limit!

    @testimonial = Testimonial.new(testimonial_params)
    @testimonial.approved = true # Auto approve or set true for instant feedback

    if @testimonial.save
      redirect_to experiences_path(anchor: "testimonials"), notice: "Thank you for sharing your reflection! Your testimonial has been published."
    else
      redirect_to experiences_path(anchor: "testimonials"), alert: "Unable to submit reflection. Please fill out required fields."
    end
  end

  private

  def testimonial_params
    params.require(:testimonial).permit(:author_name, :relationship_status, :edition_title, :quote)
  end
end
