module Geocms
  class FolderShortSerializer < ActiveModel::Serializer
    attributes :id, :slug, :name, :visibility, :personal

    has_many :contexts, embed: :objects, serializer: ContextShortSerializer

    def personal
      scope.id == object.user_id
    end
  end
end
