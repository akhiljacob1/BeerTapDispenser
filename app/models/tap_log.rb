class TapLog < ApplicationRecord
  belongs_to :dispenser

  enum type: { close: 0, open: 1 }
end
