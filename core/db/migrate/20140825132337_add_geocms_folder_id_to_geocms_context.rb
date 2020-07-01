class AddGeocmsFolderIdToGeocmsContext < ActiveRecord::Migration[4.2]
  def change
    add_column :geocms_contexts, :folder_id, :integer
  end
end
