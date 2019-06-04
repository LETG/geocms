module Geocms
  class ContextsLayerSerializer < ActiveModel::Serializer

    attributes :id, :opacity, :layer_id, :title, :description, :name, :tiled, :template, 
               :data_source_wms, :data_source_wms_version, :data_source_not_internal,
               :data_source_ogc, :data_source_name, :bbox, :position, :dimensions, :metadata_url, :max_zoom,
               :thumbnail_url, :queryable, :download_url, :type_import
    # has_one :layer

    def bbox
      object.layer.boundingbox
    end

    def dimensions
      object.layer.dimensions.map(&:value)
    end

    def queryable
      object.layer.queryable
    end
  end
end