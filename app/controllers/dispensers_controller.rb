class DispensersController < ApplicationController
  def index
    render json: Dispenser.all
  end

  def show
    render json: Dispenser.find(params[:id])
  end

  def create
    @dispenser = Dispenser.new(dispenser_params)

    if @dispenser.save
      render json: @dispenser, status: :created
    else
      render json: @dispenser.errors, status: :unprocessable_entity
    end
  end

  private

  def dispenser_params
    params.require(:dispenser).permit(:flow_volume)
  end
end
