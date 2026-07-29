module Admin
  class StoriesController < ApplicationController
    before_action :set_story, only: [:show, :edit, :update, :destroy]

    def index
      @stories = Story.order(created_at: :desc)
    end

    def show
    end

    def new
      @story = Story.new
    end

    def create
      @story = Story.new(story_params)
      if @story.save
        redirect_to admin_stories_path, notice: "Story published successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @story.update(story_params)
        redirect_to admin_stories_path, notice: "Story updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @story.destroy
      redirect_to admin_stories_path, notice: "Story deleted."
    end

    private

    def set_story
      @story = Story.find(params[:id])
    end

    def story_params
      params.require(:story).permit(:title, :category, :summary, :body, :image_url, :published, :featured)
    end
  end
end
