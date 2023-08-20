class CreateTransactions < ActiveRecord::Migration[7.0]
  def change
    create_table :transactions do |t|
      t.datetime :start_time, null: false
      t.datetime :end_time
      t.integer :total_time
      t.float :total_volume
      t.float :total_cost
      t.references :dispenser, null: false, foreign_key: true

      t.timestamps
    end
  end
end
