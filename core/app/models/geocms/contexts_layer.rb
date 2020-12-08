module Geocms
  class ContextsLayer < ActiveRecord::Base

    belongs_to :context, optional: true
    belongs_to :layer, optional: true

    delegate :title, :description, :name, :tiled, :template, :thumbnail_url,
             :data_source_wms, :data_source_wms_version, :data_source_not_internal, :download_url, :type_import,
             :data_source_ogc, :data_source_name, :bbox, :metadata_url, :max_zoom, to: :layer
    delegate :id, to: :layer, prefix: true
  end
end