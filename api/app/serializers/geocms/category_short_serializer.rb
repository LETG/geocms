module Geocms
  class CategoryShortSerializer < ActiveModel::Serializer
    attributes :id, :name, :depth, :parent_categories
  end
end
