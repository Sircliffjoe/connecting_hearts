class StoriesController < ApplicationController
  def index
    @stories = Story.published
  end

  def show
    @story = Story.find(params[:id])
    @related_stories = Story.published.where.not(id: @story.id).order(created_at: :desc).limit(3)
  end
end

