class Dispenser < ApplicationRecord
  # Enums
  enum status: { closed: 0, open: 1 }

  # Associations
  has_many :transactions

  # Validations
  validates :flow_volume, numericality: { only_float: true }

  def calculate_spend
    # Calculates current spend
    last_transaction = transactions.last
    current_open_duration = (Time.current - last_transaction.start_time).to_f
    current_volume = flow_volume * current_open_duration
    (current_volume * cost_per_litre).round(2)
  end
end
