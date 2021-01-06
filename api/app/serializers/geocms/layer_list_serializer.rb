module Geocms
  class LayerListSerializer < ActiveModel::Serializer
    attributes  :layer_id, :title, :description, :thumbnail_url, :data_source_name, :has_dimensions

    def layer_id
      object.id
    end

    def has_dimensions
      object.dimensions.size > 0
	  end
  end
end