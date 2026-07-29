class PagesController < ApplicationController
  def home
    @upcoming_event = Event.featured.first || Event.upcoming.first
    @past_events = Event.past
    @testimonials = Testimonial.approved.featured.limit(3)
    @featured_stories = Story.published.featured.limit(2)
    @founder_story = Story.find_by(category: "Founder Reflection")
    @resources = Resource.published.limit(4)
  end

  def about
    @founder_story = Story.find_by(category: "Founder Reflection")
  end

  def our_work
  end

  def counseling
  end

  def educational_support
  end

  def get_involved
  end

  def contact
  end

  def privacy
  end

  def terms
  end
end
