class TapLog < ApplicationRecord
  # Associations
  belongs_to :dispenser

  # Callbacks
  after_create :update_dispenser_status
  after_create :create_or_update_transaction

  # Enums
  enum event_type: { close: 0, open: 1 }

  private

  def update_dispenser_status
    if event_type == 'open'
      dispenser.update(status: 'open')
    else
      dispenser.update(status: 'closed')
    end
  end

  def create_or_update_transaction
    if event_type == 'open'
      Transaction.create(start_time: Time.current, dispenser:)
    else
      transaction = dispenser.transactions.last
      total_time = Time.current - transaction.start_time
      total_volume = total_time * dispenser.flow_volume
      total_cost = total_volume * dispenser.cost_per_litre

      transaction.update(
        end_time: Time.current,
        total_time:,
        total_volume:,
        total_cost:
      )
    end
  end
end
