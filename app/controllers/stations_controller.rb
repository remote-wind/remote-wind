class StationsController < ApplicationController
  skip_before_filter :authenticate_user!,
                     only: [:show, :index, :search, :embed, :find, :api_firmware_version, :update_balance]

  authorize_resource
  before_action :set_station, except: [:new, :index, :create, :find, :search]
  before_action :make_public, only: [:show, :index]

  # Skip CSRF protection since station does not send CSRF token.
  protect_from_forgery except: [:create, :update_balance, :api_firmware_version]

  # GET /stations
  # GET /stations.json
  def index
    @title = "Stations"
    if authenticated_stale?
      # @todo should be handled in autorization layer (CanCanCan)
      if user_signed_in?
        if current_user.has_role?(:admin)
          @stations = Station.all
        else
          @stations = Station.with_role(:owner, current_user)
        end
      else
        @stations = Station.visible
      end

      @stations = @stations.with_observations(1)
      @stations.load
      respond_to do |format|
        format.html
        format.json { render json: @stations }
      end
    end
  end

  # GET /stations/1
  # GET /stations/1.json
  def show
    @title = @station.name
    @observations = @station.load_observations!(10)
    if stale?(@station)
      respond_to do |format|
        format.html
        format.json { render json: @station }
      end
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
    respond_to do |format|
      if @station.save
        format.html { redirect_to station_path(@station), notice: 'Station was successfully created.' }
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

  # PATCH/PUT /stations/1/firmware_version.json
  def api_firmware_version
    if @station.update(params.require(:station).permit(:firmware_version, :gsm_software))
      head :ok
    else
      render json: @station.errors, status: :unprocessable_entity
    end
  end

  # PUT /s/:station_id
  def update_balance
    sp = params.require(:s).permit(:b)
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
      if @station.destroyed?
        format.html { redirect_to stations_url }
        format.json { head :no_content, status: :ok }
      else
        format.html { redirect_to @stations, flash: "Station could not be deleted." }
        format.json { head :no_content, status: :ok }
      end
    end
  end

  # GET /stations/search?lat=x&lon=x&radius
  def search
    radius = params[:radius] || 20
    @stations = Station.all.near([params[:lat], params[:lon]], radius, units: :km)
  end

  # GET /stations/:id/embed
  def embed
    @observation = @station.current_observation
    @observations = [@observation]
    @embed_options = {
        css: (params[:css].in?(['true', 'TRUE'])),
        type: params[:type] || 'table',
        height: params[:height] || 350,
        width: params[:width] || 500
    }

    unless @embed_options[:type].in? ['chart','table']
      @message = "Sorry buddy, I don´t know how to render \"#{@embed_options[:type]}\"."
      @embed_options[:type] = 'error'
    end

    # Temporary fix to allow iframe from http://www.gotlandssurfcenter.se
    response.headers['X-Frame-Options'] = 'ALLOW-FROM http://www.gotlandssurfcenter.se'

    respond_to do |format|
      format.html { render "/stations/embeds/#{@embed_options[:type]}", layout: false }
    end
  end

  # Used by Ardiuno to lookup station ID
  def find
    @station = Station.find_by(hw_id: params[:hw_id])
    if @station.nil?
      respond_to do |format|
        format.json { head :not_found }
      end
    else
      # Update station to show that it has been intialized
      @station.unresponsive! if @station.not_initialized?
      respond_to do |format|
        format.json { render json: { id: @station.id } }
      end
    end
  end

  private

    # Creates an etag cache key based on the latest observation
    # and the current user.
    def authenticated_stale?
      s = Station.order(updated_at: :desc).first
      # handles edge case in tests where there are no stations
      return true if s.nil?
      stale?(etag: [s, current_user], last_modified: s.try(:updated_at))
    end

    # before_action
    def set_station
      @station = Station.friendly.find(params[:id])
      logger.info action_name.to_sym
      authorize! @station, action_name.to_sym unless (action_name.to_sym).in?([:embed, :show, :update_balance, :api_firmware_version])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def station_params
      params.require(:station).permit(
        :name, :hw_id, :latitude, :longitude, :user_id, :slug,
        :show, :speed_calibration, :description, :sampling_rate,
        :status
      )
    end
end
