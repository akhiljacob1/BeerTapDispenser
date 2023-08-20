class CreateTapLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :tap_logs do |t|
      t.integer :type, null: false, default: 0
      t.references :dispenser, null: false, foreign_key: true

      t.timestamps
    end
  end
end
