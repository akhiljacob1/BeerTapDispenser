class CreateDispensers < ActiveRecord::Migration[7.0]
  def change
    create_table :dispensers do |t|
      t.float :flow_volume, null: false
      t.float :cost_per_litre, null: false
      t.integer :status, default: 0, null: false

      t.timestamps
    end
  end
end
