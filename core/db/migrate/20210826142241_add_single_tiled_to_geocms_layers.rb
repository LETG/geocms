class AddSingleTiledToGeocmsLayer < ActiveRecord::Migration[4.2]
  def change
    add_column :geocms_layers, :single_tiled, :boolean, default: false
  end
end
