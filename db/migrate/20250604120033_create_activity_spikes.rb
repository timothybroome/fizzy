class CreateActivitySpikes < ActiveRecord::Migration[8.1]
  def change
    create_table :card_activity_spikes do |t|
      t.references :card, null: false, foreign_key: true, index: true
      t.timestamps
    end
  end
end
