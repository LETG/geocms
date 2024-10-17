module Geocms
  class Authentication < ActiveRecord::Base
    belongs_to :user
  end
end