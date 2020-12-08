module Geocms
  class Folder < ActiveRecord::Base
    extend FriendlyId
    friendly_id :name, use: [:slugged, :finders]

    acts_as_tenant(:account)

    belongs_to :user, :optional => true

    has_many :contexts

    validates :user, :name, presence: true
    validates :name, uniqueness: true

    scope :ordered, -> { order(visibility: :desc).order(:name) }
  end
end