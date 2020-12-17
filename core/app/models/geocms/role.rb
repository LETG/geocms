module Geocms
  class Role < ActiveRecord::Base
    has_and_belongs_to_many :users, :join_table => :geocms_users_roles
    belongs_to :resource, :polymorphic => true, :optional => true

    scopify

    ADMIN = "admin"

    def self.available_roles(disable_admin)
      if (disable_admin)
        Role.where.not(name: ADMIN)
      else
        Role.all
      end
    end
  end
end