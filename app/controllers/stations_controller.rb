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
        @measures = @station.measures.find(:all, 
          :conditions => ["created_at > ?", 12.hours.ago], :order => "id desc").reverse
        @measures.map! { |m| 
          m.speed = @station.calibrate_speed(m.speed)
          m.min_wind_speed = @station.calibrate_speed(m.min_wind_speed)
          m.max_wind_speed = @station.calibrate_speed(m.max_wind_speed)
          m.direction /= 10
          m
        }
        @measures_short_time = @station.measures.find(:all, 
          :conditions => ["created_at > ?", 20.minutes.ago])
        @measures_short_time.map! { |m| 
          m.speed = @station.calibrate_speed(m.speed)
          m.min_wind_speed = @station.calibrate_speed(m.min_wind_speed)
          m.max_wind_speed = @station.calibrate_speed(m.max_wind_speed)
          m.direction /= 10
          m
        }
        @measures_longer_time = @station.measures.find(:all, 
          :conditions => ["created_at > ?", 1.hour.ago])
        @measures_longer_time.map! { |m| 
          m.speed = @station.calibrate_speed(m.speed)
          m.min_wind_speed = @station.calibrate_speed(m.min_wind_speed)
          m.max_wind_speed = @station.calibrate_speed(m.max_wind_speed)
          m.direction /= 10
          m
        }
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

  def show_chart
    @station = Station.find(params[:id])
    
    zone = ActiveSupport::TimeZone.create(@station.timezone)
    Time.zone = zone unless zone.nil?
        
    respond_to do |format|
      format.html {        
        @measures = @station.measures.find(:all, 
          :conditions => ["created_at > ?", 12.hours.ago], :order => "id desc").reverse
      }
    end
  end
  
  def ruben_chart
    @station = Station.find(params[:id])
    
    zone = ActiveSupport::TimeZone.create(@station.timezone)
    Time.zone = zone unless zone.nil?
    
    @measures = @station.measures.find(:all, 
      :conditions => ["created_at > ?", 12.hours.ago], :order => "id desc").reverse
    @chart_min = 20
    @chart_max = 40
        
    respond_to do |format|
      format.html {        
        render
      }
    end
  end
  # GET /stations/1/measures
  # GET /stations/1/measures.xml
  def measures
    @station = Station.find(params[:id])

    zone = ActiveSupport::TimeZone.create(@station.timezone)
    Time.zone = zone unless zone.nil?

    @measures = @station.measures.find(:all, 
      :conditions => ["created_at > ?", 12.hours.ago], :order => "id desc")
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
    @users = User.all
    @users.delete current_user
    @users.collect! {|p| [ p.email, p.id ] }
    @users.sort!
    @users.insert(0, ['me', current_user.id] )
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

  def update_balance
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
    if(!params[:s].nil?)
      logger.debug "Short form"
      params[:station] = HashWithIndifferentAccess.new
      if(!params[:s][:b].nil?)
        logger.debug "Setting station balance to #{params[:s][:b]}"
        params[:station][:balance] = params[:s][:b]
      end
      params.delete :s
      logger.debug "Parameters " + params[:station].to_s
    elsif(!params[:station].nil?)
      logger.debug "Long form"
    else
      render :status => 500, :nothing => true and return
    end
    
    respond_to do |format|
      if @station.update_attributes(params[:station])
        format.xml  { head :ok }
        format.yaml { render :status => :ok, :nothing => true }
      else
        format.xml  { render :xml => @station.errors, :status => :unprocessable_entity }
        format.yaml { render :status => :unprocessable_entity, :nothing => true }
      end
    end
  end
  
  # PUT /stations/remove/1
  def remove
    @station = Station.find(params[:id])
    @station.user = nil
    @station.save
  
    respond_to do |format|
      format.html { redirect_to(list_stations_url) }
      format.xml  { head :ok }
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
  
  def clear_measures
    @station = Station.find(params[:id])
    zone = ActiveSupport::TimeZone.create(@station.timezone)
    Time.zone = zone unless zone.nil?
    measures = @station.measures.find(:all, :order => :created_at)
    
    respond_to do |format|
      if measures.count != 0
        @start = measures.first.created_at - 1.minute
        @end = measures.last.created_at + 1.minute
        format.html
      else
        response = "No measures to delete for that station!"
        format.html { redirect_to(list_stations_path, :alert => response) }
      end
    end
  end
  
  def clear
    logger.debug("Parameters #{params}")
    @station = Station.find(params[:id])
    start_date = Time.new(params[:start_date][:year], params[:start_date][:month], params[:start_date][:day], params[:start_date][:hour], params[:start_date][:minute])

  end_date =   Time.new(params[:end_date][:year], params[:end_date][:month], params[:end_date][:day], params[:end_date][:hour], params[:end_date][:minute])
  
    measures = @station.measures.find(:all, :conditions => [" created_at between ? AND ?", start_date , end_date])
    logger.debug("Found #{measures.count} to clear")
    count = measures.count
    if count != 0
      measures.map { |x| x.destroy }
    end
    respond_to do |format|
      if count != 0
        response = "Deleted #{count} measures."
        format.html { redirect_to(list_stations_path, :notice => response ) }
      else
        response = "No measures within that time span, no deleted!"
         format.html { redirect_to(clear_measures_path, :alert => response) }
      end
    end
  end
  
  # GET 
  def assign
    # pass assigned stations as a hidden parameter and selected user
    @stations = Station.all
    @users = User.all
    @user = current_user

    respond_to do |format|
      format.html
    end
  end
  
  # POST
  def make_assignment
  end
  
  def list_current_users
    @stations = current_user.stations

    respond_to do |format|
      format.html { render :action => "list" }
    end
  end
end
