class DispensersController < ApplicationController
  before_action :set_dispenser, except: %i[index create]

  def index
    render json: Dispenser.all
  end

  def show
    if @dispenser
      render json: @dispenser
    else
      render json: { error: 'Dispenser not found' }, status: :not_found
    end
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

  def calculate_spend
    if @dispenser&.open?
      render json: { current_spend: @dispenser.calculate_spend }
    elsif @dispenser&.closed?
      render json: { error: 'Tap is not open currently.' }, status: :unprocessable_entity
    else
      render json: { error: 'Tap not found' }, status: :not_found
    end
  end

  private

  def set_dispenser
    @dispenser = Dispenser.find_by(id: params[:id])
  end

  def dispenser_params
    params.require(:dispenser).permit(:flow_volume, :cost_per_litre)
  end
end
