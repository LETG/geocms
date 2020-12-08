module Geocms
  class Categorization < ActiveRecord::Base
    belongs_to :category, :optional => true
    belongs_to :layer, :optional => true
  end
end
