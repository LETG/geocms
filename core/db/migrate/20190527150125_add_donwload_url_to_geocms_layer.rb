class AddDonwloadUrlToGeocmsLayer < ActiveRecord::Migration
  def change
    add_column :geocms_layers, :download_url, :string
  end
end
