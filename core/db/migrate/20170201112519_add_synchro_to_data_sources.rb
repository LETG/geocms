class AddSynchroToDataSources < ActiveRecord::Migration[4.2]
  def change
    add_column :geocms_data_sources, :synchro, :boolean
  end
end
