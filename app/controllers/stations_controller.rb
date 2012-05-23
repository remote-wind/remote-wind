class StationsController < ApplicationController
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
    @station = Station.new(params[:station])
    # set station timezone if station lat and lon given
    if(!@station.lat.nil? && !@station.lon.nil?)
      places = flickr.places.findByLatLon(:lat => @station.lat, :lon => @station.lon)
      zone = ActiveSupport::TimeZone::MAPPING.invert[places.first.timezone]
      @station.timezone  = zone unless zone.nil?
    end

    respond_to do |format|
      if @station.save
        format.html { redirect_to(@station, :notice => 'Station was successfully created.') }
        format.xml  { render :xml => @station, :status => :created, :location => @station }
      else
        format.html { render :action => "new" }
        format.xml  { render :xml => @station.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /stations/1
  # PUT /stations/1.xml
  def update
    @station = Station.find(params[:id])
    # set station timezone if station lat and lon given
    if(!@station.lat.nil? && !@station.lon.nil?)
      places = flickr.places.findByLatLon(:lat => @station.lat, :lon => @station.lon)
      zone = ActiveSupport::TimeZone::MAPPING.invert[places.first.timezone]
      @station.timezone  = zone unless zone.nil?
    end
    
    respond_to do |format|
      if @station.update_attributes(params[:station])
        format.html { redirect_to(@station, :notice => 'Station was successfully updated.') }
        format.xml  { head :ok }
      else
        format.html { render :action => "edit" }
        format.xml  { render :xml => @station.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /stations/1
  # DELETE /stations/1.xml
  def destroy
    @station = Station.find(params[:id])
    @station.destroy

    respond_to do |format|
      format.html { redirect_to(stations_url) }
      format.xml  { head :ok }
    end
  end
end
