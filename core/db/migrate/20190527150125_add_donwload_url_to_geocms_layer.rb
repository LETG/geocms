class AddDonwloadUrlToGeocmsLayer < ActiveRecord::Migration[4.2]
  def change
    add_column :geocms_layers, :download_url, :string
  end
end
