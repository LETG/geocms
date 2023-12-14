module Geocms
  class LayerThumbnailWorker
    include Sidekiq::Worker

    def perform(layer_id, data_source, crs, bbox)
      layer = Geocms::Layer.find layer_id
      remote_thumbnail_url = ROGC::WMSClient.get_map(data_source, layer.name, layer.default_style, bbox, 64, 64, crs)
      #update_column skip model callback (after commit update)
      layer.update_column(:remote_thumbnail_url, remote_thumbnail_url)
    end

  end
end
