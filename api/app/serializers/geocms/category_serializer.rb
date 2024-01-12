module Geocms
  class CategorySerializer < ActiveModel::Serializer
    has_many :layers, serializer: LayerListSerializer, embed: :objects
    has_many :children, serializer: CategoryShortSerializer, embed: :objects

    attributes :id, :name, :parent_categories

    def children
      object.children.ordered
    end

  end
end
