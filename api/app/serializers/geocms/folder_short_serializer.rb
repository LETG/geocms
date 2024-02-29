module Geocms
  class FolderShortSerializer < ActiveModel::Serializer
    attributes :id, :slug, :name, :visibility, :personal

    has_many :contexts, embed: :objects, serializer: ContextShortSerializer

    def personal
      # If scope is defined, we check if folder user id is the same as the current_user. This allow to add property "personal" to indicate if folder belongs to the user
      scope.present? ? scope.id == object.user_id : false
    end
  end
end
