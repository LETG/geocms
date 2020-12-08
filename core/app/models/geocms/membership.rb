module Geocms
  class Membership < ActiveRecord::Base

    belongs_to :account, :optional => true
    belongs_to :user, :optional => true

  end
end