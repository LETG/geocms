class AddAccountToDataSources < ActiveRecord::Migration[4.2]
  def change
    add_column :geocms_data_sources, :account_id, :integer
  end
end
