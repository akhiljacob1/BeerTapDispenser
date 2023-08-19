class Dispenser < ApplicationRecord
  enum status: { closed: 0, open: 1 }
end
