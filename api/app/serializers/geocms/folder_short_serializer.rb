module Geocms
  class FolderShortSerializer < ActiveModel::Serializer
    attributes :id, :slug, :name, :visibility

    has_many :contexts, embed: :objects, serializer: ContextShortSerializer
  end
end
