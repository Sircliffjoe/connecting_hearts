class ExperiencesController < ApplicationController
  include SpamProtection

  def index
    scope = Event.order(event_date: :desc)
    
    if params[:location].present? && params[:location] != "all"
      if params[:location] == "warri"
        scope = scope.where("LOWER(location) LIKE ?", "%warri%")
      elsif params[:location] == "online"
        scope = scope.where("LOWER(location) LIKE ? OR LOWER(location) LIKE ?", "%online%", "%virtual%")
      end
    end

    if params[:date] == "upcoming"
      scope = scope.upcoming
    elsif params[:date] == "past"
      scope = scope.past
    end

    @events = scope
    @featured_event = @events.find { |e| e[:featured] } || Event.featured.first || @events.first
    @past_events = Event.past
    @upcoming_events = Event.upcoming

    @testimonials = Testimonial.approved.order(created_at: :desc).limit(6)
  end

  def show
    @event = Event.find_by(id: params[:id]) || Event.find_by("LOWER(title) LIKE ?", "%#{params[:id].to_s.tr('-', ' ')}%") || Event.first
    @related_events = Event.where.not(id: @event&.id).order(event_date: :desc).limit(3)
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
