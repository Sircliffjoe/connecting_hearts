class StoriesController < ApplicationController
  def index
    @stories = Story.published
  end

  def show
    @story = Story.find(params[:id])
  end
end
