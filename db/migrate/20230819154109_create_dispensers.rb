class CreateDispensers < ActiveRecord::Migration[7.0]
  def change
    create_table :dispensers do |t|
      t.float :flow_volume
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
