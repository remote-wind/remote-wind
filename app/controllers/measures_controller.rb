class MeasuresController < ApplicationController
  # GET /measures
  # GET /measures.xml
  def index
    @measures = Measure.all

    respond_to do |format|
      format.html # index.html.erb
      format.xml  { render :xml => @measures }
    end
  end

  # GET /measures/1
  # GET /measures/1.xml
  def show
    @measure = Measure.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.xml  { render :xml => @measure }
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
