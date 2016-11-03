class ObservationsController < ApplicationController

  skip_before_filter :authenticate_user!, only: [:create, :index] # Ardiuno needs to be able to post without auth.
  protect_from_forgery        only: [:destroy, :clear]
  before_action :set_station, only: [:index, :clear, :create]
  before_action :make_public, only: [:index] # Sets CORS headers to allow cross-site sharing

  # Checks the up/down heuristics after creating an observation.
  # Could possible be moved to a job after Rails 5 update.
  after_action ->{ @station.check_status! unless @station.nil? }, only: :create

  # POST /stations/:station_id/observations
  def create
    # Find station via ID or SLUG
    @observation = @station.observations.new(permitted_attributes(Observation))
    authorize @observation
    if @observation.save
      render nothing: true, status: :ok
    else
      render nothing: true, status: :unprocessable_entity
    end
  end

  # GET /stations/:station_id/observations
  def index
    expires_in expiry_time(@station), public: true
    if stale?(@station)
      respond_to do |format|
        @observations = @station.observations
        format.html do
          @observations = @observations.desc
                       .paginate(page: params[:page])
        end
        format.json do
          @observations = @station.load_observations!(
              @station.observations_per_day,
              query: Observation.desc.since(24.hours.ago)
          )
          render json: @observations
        end
      end
    end
  end

  # DELETE /observations/:id
  def destroy
    @observation = Observation.find(params[:id])
    @station = @observation.station
    authorize(@observation)
    @observation.destroy
    respond_to do |format|
      format.html { redirect_to station_observations_path(@station) }
      format.json { head :no_content }
    end
  end

  # DELETE /stations/:station_id/observations
  def clear
    authorize(@station, :update?)
    # get station with Friendly Id, params[:id] can either be id or slug
    Observation.delete_all("station_id = #{@station.id}")
    respond_to do |format|
      format.html { redirect_to station_url(@station) }
      format.json { head :no_content }
    end
  end

  private

    # get station with Friendly ID as params[:id] can either be id or slug
    def set_station
      @station = Station.friendly.find(params[:station_id])
    end

    def observation_params
      params.require(:observation).permit(
        :id, :station_id, :direction, :speed, :min_wind_speed, :max_wind_speed
      )
    end

    def expiry_time(station)
      t = station.next_observation_expected_in
      # checks if station is overdue for reporting in which case it sets the
      # expiry to 1 minute to encourage the client (browser) to check again.
      t > 0 ? t : 1.minute
    end
end
