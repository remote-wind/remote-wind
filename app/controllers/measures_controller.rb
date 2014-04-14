class MeasuresController < ApplicationController

  skip_before_filter :authenticate_user!, :only => [:create, :index]
  load_and_authorize_resource :only => [:destroy, :index, :clear]
  protect_from_forgery :only => [:destroy]
  skip_authorization_check only: [:create]
  before_action :set_station, only: [:index, :clear]

  # POST /measures
  def create
    # Find station via ID or SLUG
    @measure = Measure.new(measure_params)

    respond_to do |format|
      if @measure.save
        @station = @measure.station
        @station.check_status!
        format.yaml { render nothing: true, status: :ok }
      else
        format.yaml { render nothing: true, status: :unprocessable_entity }
      end
    end
  end

  # GET /stations/:staton_id/measures
  def index
    expires_in 2.minutes, public: true

    # Avoid E-tag cache for dev environment
    stale = Rails.env.production? ?
        stale?(etag: @station, last_modified: @station.last_measure_received_at) : true

    if stale
      respond_to do |format|
        format.html { @measures = @station.measures.order(created_at: :desc).paginate(page: params[:page]) }
        format.json { @measures = @station.get_calibrated_measures }
      end
    end
  end

  # DELETE /measures/:id
  def destroy
    @measure = Measure.find(params[:id])
    @measure.destroy
    respond_to do |format|
      format.html { redirect_to measures_path }
      format.json { head :no_content }
    end
  end

  # DELETE /stations/:staton_id/measures
  def clear
    # get station with Friendly Id, params[:id] can either be id or slug
    Measure.delete_all("station_id = #{@station.id}")
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
    def measure_params
      ## Handle short form params
      if params[:m]
        return params.require(:m).permit(:i,:s,:d,:min,:max)
      end
      params.require(:measure).permit(
          :id, :station_id, :direction, :speed, :min_wind_speed, :max_wind_speed
      )
    end
end
