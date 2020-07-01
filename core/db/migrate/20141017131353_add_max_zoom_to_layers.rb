class AddMaxZoomToLayers < ActiveRecord::Migration[4.2]
  def change
    add_column :geocms_layers, :max_zoom, :integer, default: 19
  end
end
