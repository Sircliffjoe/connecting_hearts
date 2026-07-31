module Admin
  class EventsController < ApplicationController
    before_action :set_event, only: [:show, :edit, :update, :destroy]

    def index
      @events = Event.all.order(event_date: :desc)
    end

    def show
    end

    def new
      @event = Event.new
    end

    def create
      @event = Event.new(event_params)
      if @event.save
        # Sync event with Eventro API (eventro.africa)
        EventroApiService.create_event(@event)
        redirect_to admin_events_path, notice: "Event created successfully and synced with Eventro API."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @event.update(event_params)
        # Sync updated event details with Eventro API (eventro.africa)
        EventroApiService.create_event(@event)
        redirect_to admin_events_path, notice: "Event updated successfully and synced with Eventro API."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @event.destroy
      redirect_to admin_events_path, notice: "Event deleted."
    end

    private

    def set_event
      @event = Event.find(params[:id])
    end

    def event_params
      params.require(:event).permit(:title, :edition_number, :event_date, :location, :theme, :description, :featured, :registration_link, :capacity, :image_url)
    end
  end
end
