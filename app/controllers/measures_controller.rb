class MeasuresController < ApplicationController
  # GET /measures
  # GET /measures.xml
  def index
    @measures = Measure.all

    respond_to do |format|
      format.html # index.html.erb
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
  def create
    @measure = Measure.new(params[:measure])

    respond_to do |format|
      if @measure.save
        render :status => 200, :nothing => true and return
      else
        render :status => 500, :nothing => true and return
      end
    end
  end

end
