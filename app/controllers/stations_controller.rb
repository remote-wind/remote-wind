class StationsController < ApplicationController
  before_filter :authenticate_user!, :except => [:show, :index, :measures, :search, :embed, :find]
  authorize_resource :except => [:show, :index, :measures, :search, :embed, :find]
  before_action :set_station, only: [:edit, :update, :destroy]

  # GET /stations
  # GET /stations.json
  def index
    @stations = @all_stations
  end

  # GET /stations/1
  # GET /stations/1.json
  def show
    # get station with Friendly Id, params[:id] can either be id or slug
    @station = Station.friendly.find(params[:id])
    @measures = @station.measures.limit(10).order(created_at: :desc)
  end

  # GET /stations/new
  def new
    @station = Station.new
  end

  # GET /stations/1/edit
  def edit
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

    unless params[:station][:show].nil?
      params[:station][:show] = params[:station][:show] == 'yes'
    end

    respond_to do |format|
      if @station.update(station_params)
        format.html { redirect_to @station, notice: 'Station was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @station.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /stations/1
  # DELETE /stations/1.json
  def destroy
    @station.destroy
    respond_to do |format|
      format.html { redirect_to stations_url }
      format.json { head :no_content }
    end
  end

  # GET /stations/:staton_id/measures
  def measures
    # get station with Friendly Id, params[:id] can either be id or slug
    @station = Station.includes(:measures).friendly.find(params[:station_id])

    respond_to do |format|
      format.html { @measures = Measure.order(created_at: :desc).paginate(page: params[:page]) }
      format.json { @measures = @station.get_calibrated_measures }
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

    # Never trust parameters from the scary internet, only allow the white list through.
    def station_params
      params.require(:station).permit(:name, :hw_id, :latitude, :longitude, :user_id, :slug, :show, :speed_calibration)
    end
end