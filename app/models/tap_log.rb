class TapLog < ApplicationRecord
  # Associations
  belongs_to :dispenser

  # Callbacks
  after_create :update_dispenser_status

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
end
