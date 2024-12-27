module Geocms
  class LayerThumbnailWorker
    include Sidekiq::Worker

    def perform(layer_id, data_source, crs, bbox)
      layer = Geocms::Layer.find layer_id
      remote_thumbnail_url = ROGC::WMSClient.get_map(data_source, layer.name, layer.default_style, bbox, 64, 64, crs)
      logger.info "remote url : #{remote_thumbnail_url}"
      layer.remote_thumbnail_url = ROGC::WMSClient.get_map(data_source, layer.name, layer.default_style, bbox, 64, 64, crs)  
      layer.skip_get_thumbnail = true
      layer.save!
    end

  end
end
