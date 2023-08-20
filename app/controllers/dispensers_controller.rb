class DispensersController < ApplicationController
  before_action :set_dispenser, except: %i[index create]

  def index
    render json: Dispenser.all
  end

  def show
    render json: @dispenser
  end

  def create
    @dispenser = Dispenser.new(dispenser_params)

    if @dispenser.save
      render json: @dispenser, status: :created
    else
      render json: @dispenser.errors, status: :unprocessable_entity
    end
  end

  def open
    if @dispenser.open?
      render json: { message: 'Tap is already open.' }, status: :unprocessable_entity
    else
      TapLog.create(dispenser: @dispenser, event_type: 'open')
      render json: { message: 'Tap opened successfully.' }, status: :ok
    end
  end

  def close
    if @dispenser.closed?
      render json: { message: 'Tap is already closed.' }, status: :unprocessable_entity
    else
      TapLog.create(dispenser: @dispenser, event_type: 'close')
      render json: { message: 'Tap closed successfully.' }, status: :ok
    end
  end

  private

  def set_dispenser
    @dispenser = Dispenser.find(params[:id])
  end

  def dispenser_params
    params.require(:dispenser).permit(:flow_volume)
  end
end
