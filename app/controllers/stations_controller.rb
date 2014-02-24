class StationsController < ApplicationController

  # Security exceptions:
  DO_NOT_AUTHORIZE =  [:show, :index, :measures, :search, :embed, :find, :update_balance]

  skip_before_filter :authenticate_user!, only: DO_NOT_AUTHORIZE
      authorize_resource except: DO_NOT_AUTHORIZE
  skip_authorization_check only: DO_NOT_AUTHORIZE


  skip_before_filter :get_all_stations, only: [:update, :destroy]


  before_action :set_station, only: [:update, :destroy]
  before_action :select_station, only: [:show, :edit]

  # Skip CSRF protection since station does not send CSRF token.
  protect_from_forgery :except => [:create, :update_balance]

  # GET /stations
  # GET /stations.json
  def index
    @title = "Stations"
    @stations = @all_stations
  end

  # GET /stations/1
  # GET /stations/1.json
  def show
    @title = @station.name
    @measures = Measure.where(station_id: @station.id).joins(:station).limit(10).order(created_at: :desc)
    respond_to do |format|
      format.html #show.html.erb
    end
  end

  # GET /stations/new
  def new
    @station = Station.new
  end

  # GET /stations/1/edit
  def edit
    @title = "Editing #{@station.name}"
  end

  # POST /stations
  # POST /stations.json
  def create
    @station = Station.new(station_params)

    unless params[:station][:show].nil?
      @station.show = params[:station][:show] == 'yes'
    end

    respond_to do |format|
      if @station.save
        #expire_fragment('all_stations')
        format.html { redirect_to @station, notice: 'Station was successfully created.' }
        format.json { render action: 'show', status: :created, location: @station }
      else
        format.html { render action: 'new' }
        format.json { render json: @station.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /stations/1
  # PATCH/PUT /stations/1.json
  def update
    @station = Station.friendly.find(params[:id])
    unless params[:station][:show].nil?
      params[:station][:show] = params[:station][:show] == 'yes'
    end

    respond_to do |format|
      if @station.update(station_params)
        expire_fragment('all_stations')
        format.html { redirect_to @station, notice: 'Station was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @station.errors, status: :unprocessable_entity }
      end
    end
  end

  # @throws ActiveRecord::RecordNotFound if no station
  # PUT /s/:station_id
  def update_balance

    sp = params.require(:s).permit(:b)

    @station = Station.friendly.find(params[:station_id])
    @station.balance = sp[:b] if sp[:b].present?

    respond_to do |format|
      if @station.balance_changed? && @station.save
        format.any { render nothing: true, status: :ok }
        # check station balance after reply has been sent
        @station.check_balance
      else
        logger.error( "Someone attemped to update #{@station.name} balance with invalid data ('#{params[:s][:b]}') from #{request.remote_ip}" )
        format.any { render nothing: true, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stations/1
  # DELETE /stations/1.json
  def destroy
    @station.destroy
    expire_fragment('all_stations')
    respond_to do |format|
      format.html { redirect_to stations_url }
      format.json { head :no_content }
    end
  end

  # GET /stations/:staton_id/measures
  def measures
    # get station with Friendly Id, params[:id] can either be id or slug
    @station = Station.friendly.find(params[:station_id])
    expires_in 2.minutes, public: true

    if stale?(etag: @station, last_modified: @station.last_measure_received_at)
      respond_to do |format|
        format.html { @measures = @station.measures.order(created_at: :desc).paginate(page: params[:page]) }
        format.json { @measures = @station.get_calibrated_measures }
      end
    end
  end

  # DELETE /stations/:staton_id/measures
  def destroy_measures
    # get station with Friendly Id, params[:id] can either be id or slug
    @station = Station.friendly.find(params[:station_id])
    Measure.delete_all("station_id = #{@station.id}")
    respond_to do |format|
      format.html { redirect_to station_url(@station) }
      format.json { head :no_content }
    end
  end

  # GET stations/search?lat=x&lon=x&radius
  def search
    lat = params[:lat]
    lon = params[:lon]
    radius = params[:radius] || 20
    @stations = Station.near([lat, lon], radius, :units => :km)
  end

  def embed
    # get station with Friendly Id, params[:id] can either be id or slug
    @station = Station.friendly.find(params[:station_id])
    @measure = @station.current_measure
    @css = params[:css].in? [true, 'true', 'TRUE']
    @type = params[:type] || 'table'
    @height = params[:height] || 350
    @width = params[:width] || 500

    unless @type.in? ['chart','table']
      @message = "Sorry buddy, I don´t know how to render \"#{@type}\"."
      @type = 'error'
    end

    respond_to do |format|
      format.html { render "/stations/embeds/#{@type}", layout: false }
    end
  end

  def find
    @station = Station.find_by_hw_id(params[:hw_id])
    if(@station.nil?)
      respond_to do |format|
        format.html { head :not_found }
        format.xml  { head :not_found }
        format.json { head :not_found }
        format.yaml { head :not_found, :content_type => 'text/x-yaml'}
      end
    else
      respond_to do |format|
        format.html # show.html.erb
        format.xml  { render :xml => @station }
        format.json  { render :json => @station }
        format.yaml {render :json =>  {
            :id    => @station.id,
            :hw_id => @station.hw_id
        }, :content_type => 'text/x-yaml'}
      end
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_station
      # get station with Friendly Id, params[:id] can either be id or slug
      @station = Station.friendly.find(params[:id])
    end

    def select_station
      @station = @all_stations.select_by_slug_or_id(params[:id])
      unless @station
        throw ActiveRecord::RecordNotFound.new(
                  "Station with id or slug = '#{params[:id]}' cannot be found" )
      end
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def station_params
      params.require(:station).permit(:name, :hw_id, :latitude, :longitude, :user_id, :slug, :show, :speed_calibration)
    end
end