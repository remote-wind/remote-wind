class ObservationsController < ApplicationController

  skip_before_filter :authenticate_user!, :only => [:create, :index]
  load_and_authorize_resource :only => [:destroy, :index, :clear]
  protect_from_forgery :only => [:destroy]
  skip_authorization_check only: [:create]
  before_action :set_station, only: [:index, :clear]

  # POST /observations
  def create
    # Find station via ID or SLUG
    @observation = Observation.new(observation_params)
    respond_to do |format|
      if @observation.save
        @station = @observation.station
        @station.check_status!
        format.yaml { render nothing: true, status: :ok }
      else
        format.yaml { render nothing: true, status: :unprocessable_entity }
      end
    end
  end

  # GET /stations/:staton_id/observations
  def index

    expires_in @station.next_observation_expected_in,
               public: true

    if stale?(@station, last_modified: @station.last_observation_received_at)
      respond_to do |format|
        format.html { @observations = @station.observations.order(created_at: :desc).paginate(page: params[:page]) }
        format.json do
          @observations = @station.get_calibrated_observations
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

  # DELETE /stations/:staton_id/observations
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
      ## Handle short form params

      if params[:m]
        return params.require(:m).permit(:i,:s,:d,:min,:max)
      end
      params.require(:observation).permit(
          :id, :station_id, :direction, :speed, :min_wind_speed, :max_wind_speed
      )
    end
end
