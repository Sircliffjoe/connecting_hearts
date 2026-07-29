module Admin
  class ResourcesController < ApplicationController
    def index
      @resources = Resource.order(created_at: :desc)
    end
  end
end
