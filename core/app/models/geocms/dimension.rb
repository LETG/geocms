module Geocms
  class Dimension < ActiveRecord::Base
    belongs_to :layer, :optional => true

    default_scope -> { order("value ASC") }

    validates :value, uniqueness: { scope: :layer_id }

  end
end