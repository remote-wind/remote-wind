class MeasuresController < ApplicationController
  # GET /measures
  # GET /measures.xml
  def index
    @measures = Measure.all
    
    respond_to do |format|
      format.html {
        previous = nil;
        @measures.each do |m|
          if(previous.nil?) then
            m.time_diff = 0
          else 
            m.time_diff = m.created_at-previous.created_at
          end
          previous = m
        end
      }
      format.xml  { render :xml => @measures }
      format.json  {render :json =>  @measures}
      format.yaml {render :json =>  @measures.map { |m| {
             :id   => m.id,
             :speed => m.speed,
             :dir => m.direction,
             :st_id => m.station_id
      }}, :content_type => 'text/x-yaml'}
    end
  end

  # GET /measures/1
  # GET /measures/1.xml
  def show
    @measure = Measure.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @measure }
      format.json  {render :json =>  @measure}
      format.yaml {render :json =>  {
             :id   => @measure.id,
             :speed => @measure.speed,
             :dir => @measure.direction,
             :st_id => @measure.station_id
      }, :content_type => 'text/x-yaml'}
    end
  end


  # POST /measures
  # POST /measures.xml
  #s    "speed"
  #d    "direction"
  #i "station_id"
  #max    "max_wind_speed"
  #min    "min_wind_speed"
  #t    "temperature"
  def create
    if(!params[:m].nil?)
      logger.debug "Short form"
      # parse out parameters from our short format and rebuild params as it normally look like
      params[:measure] = HashWithIndifferentAccess.new
      if(!params[:m][:s].nil?)
        params[:measure][:speed] = params[:m][:s]
      end
      if(!params[:m][:d].nil?)
        params[:measure][:direction] = params[:m][:d]
      end
      if(!params[:m][:i].nil?)
        params[:measure][:station_id] = params[:m][:i]
      end
      if(!params[:m][:max].nil?)
        params[:measure][:max_wind_speed] = params[:m][:max]
      end
      if(!params[:m][:min].nil?)
        params[:measure][:min_wind_speed] = params[:m][:min]
      end
      if(!params[:m][:t].nil?)
        params[:measure][:temperature] = params[:m][:t]
      end
      params.delete :m
      logger.debug "Parameters " + params[:measure].to_s
      @measure = Measure.new(params[:measure])
    elsif(!params[:measure].nil?)
      logger.debug "Long form"
      @measure = Measure.new(params[:measure])
    else
      render :status => 500, :nothing => true and return
    end
    respond_to do |format|
      if @measure.save
        render :status => 200, :nothing => true and return
      else
        render :status => 500, :nothing => true and return
      end
    end
  end

end
