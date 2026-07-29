class ResourcesController < ApplicationController
  def index
    @resources = Resource.published.by_category(params[:category]).by_type(params[:type])
    @categories = Resource::CATEGORIES
    @types = Resource::TYPES
  end

  def show
    @resource = Resource.find(params[:id])
  end
end
