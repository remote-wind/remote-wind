class MeasuresController < ApplicationController

  skip_before_filter :authenticate_user!, :only => [:create]
  load_and_authorize_resource :only => [:destroy]
  protect_from_forgery :only => [:destroy]
  skip_authorization_check only: [:create]

  # POST /measures
  def create
    # Find station via ID or SLUG
    @measure = Measure.new(measure_params)

    respond_to do |format|

      unless request.format == 'yaml'
        render nothing: true, status: :bad_request and return
      end

      if @measure.save
        @station = @measure.station
        @station.check_status!

        format.yaml { render nothing: true, status: :ok }
      else

        format.yaml { render nothing: true, status: :unprocessable_entity }
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

  private
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
