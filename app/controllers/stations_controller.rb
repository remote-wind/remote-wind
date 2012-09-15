class StationsController < ApplicationController
  load_and_authorize_resource
  # GET /stations
  # GET /stations.xml
  def index
    @stations = Station.all

    respond_to do |format|
      format.html {
        @stations.each do |s|
          unless s.current_measure.nil?
            logger.debug s.current_measure.id
            logger.debug s.current_measure.speed
          end
        end
      }
      format.xml  { render :xml => @stations }
      format.json  {render :json =>  @stations}
      format.yaml {render :json =>  @stations.map { |m| {
             :id   => m.id,
             :name => m.name,
             :hw_id => m.hw_id,
             :lat => m.lat,
             :lon => m.lon
      }}, :content_type => 'text/x-yaml'}
    end
  end

  # GET /stations/1
  # GET /stations/1.xml
  def show
    @station = Station.find(params[:id])
    logger.debug @station.timezone
    
    zone = ActiveSupport::TimeZone.create(@station.timezone)
    Time.zone = zone unless zone.nil?
        
    respond_to do |format|
      format.html {        
        @measures = @station.measures.find(:all, :limit => 144, :order => "id desc").reverse
      }
      format.xml  { render :xml => @station }
      format.json  {render :json =>  @station}
      format.yaml {render :json =>  {
                  :id   => @station.id,
                 :name => @station.name,
                 :hw_id => @station.hw_id,
                 :lat => @station.lat,
                 :lon => @station.lon
          }, :content_type => 'text/x-yaml'}
    end
  end

  # GET /stations/1/measures
  # GET /stations/1/measures.xml
  def measures
    @station = Station.find(params[:id])

    zone = ActiveSupport::TimeZone.create(@station.timezone)
    Time.zone = zone unless zone.nil?

    @measures = @station.measures.find(:all, :order => "id desc")
    respond_to do |format|
      format.html {
        previous = nil;
        @measures.each do |m|
          if(previous.nil?) then
            m.time_diff = 0
          else 
            m.time_diff = previous.created_at-m.created_at
          end
          previous = m
        end
      }
      format.xml  { render :xml => @measures }
      format.json  {render :json =>  @measures}
    end
  end

  def list
    @stations = Station.all

    respond_to do |format|
      format.html # index.html.erb
    end
  end

  # GET /stations/1
  # GET /stations/1.xml
  def find
    @station = Station.find_by_hw_id(params[:imei])

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
  
  # GET /stations/new
  # GET /stations/new.xml
  def new
    @station = Station.new
    
    @users = User.all
    @users.delete current_user
    @users.collect! {|p| [ p.email, p.id ] }
    @users.sort!
    @users.insert(0, ['me', current_user.id] )

    respond_to do |format|
      format.html # new.html.erb
      format.xml  { render :xml => @station }
    end
  end

  # GET /stations/1/edit
  def edit
    @station = Station.find(params[:id])
  end

  # POST /stations
  # POST /stations.xml
  def create
    if !params[:user].nil? && !params[:user][:email].nil?
      user = User.find_by_email(params[:user][:email])
      if !user.nil?
        if params[:station][:user_id]!=''
          # user also selected a user from the dropdown, ignore that and use the entered email
          params[:station].delete :user_id
        end
        params[:station][:user_id] = user.id
        params.delete :user
      else
        invitation_email = params[:user][:email]
        params.delete :user
      end
    end
    logger.debug("Parameters #{params}")
    if params[:station][:user_id]==''
      params[:station].delete :user_id
    end
    @station = Station.new(params[:station])
    logger.debug("@station " + @station.inspect)
    # set station timezone if station lat and lon given
    if(!@station.lat.nil? && !@station.lon.nil?)
      logger.debug("Lat: " + @station.lat.to_s + " Lon: " + @station.lon.to_s)
      places = flickr.places.findByLatLon(:lat => @station.lat, :lon => @station.lon)
      logger.debug("Places: " + places.inspect)
      zone = ActiveSupport::TimeZone::MAPPING.invert[places.first.timezone]
      logger.debug("Zone: " + zone.inspect)
      @station.timezone  = zone unless zone.nil?
    else
      logger.debug("Lat/Lon not set")
      @station.timezone = nil
    end

    # create users list if the station cannot be created
    @users = User.all
    @users.delete current_user
    @users.collect! {|p| [ p.email, p.id ] }
    @users.sort!
    @users.insert(0, ['me', current_user.id] )
    
    respond_to do |format|
      if @station.save
        if !invitation_email.nil?
          logger.debug("Invite #{invitation_email}")
          User.invite!(:email => invitation_email, :stations => @station)
          AdminMailer.notify_about_new_station_and_invitation(invitation_email, @station).deliver
        elsif @station.user.nil?
          AdminMailer.notify_about_new_station_without_owner(@station).deliver
        else
          UserMailer.notify_about_new_station(@station.user, @station).deliver
        end
        format.html { redirect_to(@station, :notice => 'Station was successfully created.') }
        format.xml  { render :xml => @station, :status => :created, :location => @station }
        format.yaml { render :status => :ok, :nothing => true }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @station.errors, :status => :unprocessable_entity }
        format.yaml { render :status => :unprocessable_entity, :nothing => true }
      end
    end
  end

  # PUT /stations/1
  # PUT /stations/1.xml
  def update
    @station = Station.find(params[:id])
    logger.debug("@station " + @station.inspect)
    # set station timezone if station lat and lon given
    if(!@station.lat.nil? && !@station.lon.nil?)
      logger.debug("Lat: " + @station.lat.to_s + " Lon: " + @station.lon.to_s)
      places = flickr.places.findByLatLon(:lat => @station.lat, :lon => @station.lon)
      logger.debug("Places: " + places.inspect)
      zone = ActiveSupport::TimeZone::MAPPING.invert[places.first.timezone]
      logger.debug("Zone: " + zone.inspect)
      @station.timezone  = zone unless zone.nil?
    else
      logger.debug("Lat/Lon not set")
      @station.timezone = nil
    end
    
    respond_to do |format|
      if @station.update_attributes(params[:station])
        format.html { redirect_to(@station, :notice => 'Station was successfully updated.') }
        format.xml  { head :ok }
        format.yaml { render :status => :ok, :nothing => true }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @station.errors, :status => :unprocessable_entity }
        format.yaml { render :status => :unprocessable_entity, :nothing => true }
      end
    end
  end

  # DELETE /stations/1
  # DELETE /stations/1.xml
  def destroy
    @station = Station.find(params[:id])
    @station.destroy

    respond_to do |format|
      format.html { redirect_to(list_stations_url) }
      format.xml  { head :ok }
    end
  end
end
