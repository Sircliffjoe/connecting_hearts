module Admin
  class ResourcesController < ApplicationController
    before_action :set_resource, only: [:show, :edit, :update, :destroy]

    def index
      @resources = Resource.order(created_at: :desc)
    end

    def show
    end

    def new
      @resource = Resource.new
    end

    def create
      @resource = Resource.new(resource_params)
      if @resource.save
        redirect_to admin_resources_path, notice: "Resource created successfully."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @resource.update(resource_params)
        redirect_to admin_resources_path, notice: "Resource updated successfully."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @resource.destroy
      redirect_to admin_resources_path, notice: "Resource deleted."
    end

    private

    def set_resource
      @resource = Resource.find(params[:id])
    end

    def resource_params
      params.require(:resource).permit(:title, :category, :resource_type, :summary, :content, :file_url, :external_link, :published, :image_url, gallery_images: [])
    end
  end
end
