class ObservationsController < ApplicationController

  skip_before_filter :authenticate_user!, only: [:create, :index] # Ardiuno needs to be able to post without auth.
  load_and_authorize_resource

  protect_from_forgery        only: [:destroy, :clear]
  before_action :set_station, only: [:index, :clear, :create]
  before_action :make_public, only: [:index] # Sets CORS headers to allow cross-site sharing

  # Send response first when creating an observation.
  after_action ->{ @station.check_status! unless @station.nil? }, only: :create

  # POST /observations
  def create
    # Find station via ID or SLUG
    @observation = Observation.new(observation_params)
    if @observation.station.nil? && !@station.nil?
      @observation.station = @station
    end
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
    @observation.destroy
    respond_to do |format|
      format.html { redirect_to station_observations_path(@station) }
      format.json { head :no_content }
    end
  end

  # DELETE /stations/:station_id/observations
  def clear
    # get station with Friendly Id, params[:id] can either be id or slug
    Observation.delete_all("station_id = #{@station.id}")
    respond_to do |format|
      format.html { redirect_to station_url(@station) }
      format.json { head :no_content }
    end
  end

  private

    def set_station
      # get station with Friendly Id, params[:id] can either be id or slug
      @station = Station.friendly.find(params[:station_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def observation_params
      logger.info "Observation Controller with params: " + params.to_s
      params.require(:observation).permit(
          :id, :station_id, :direction, :speed, :min_wind_speed, :max_wind_speed
      )
    end

    def expiry_time(station)
      t = station.next_observation_expected_in
      # checks if station is overdue for reporting in which case it sets the
      # expiry to 1 minute to encourage the client to check again.
      t > 0 ? t : 1.minute
    end
end
