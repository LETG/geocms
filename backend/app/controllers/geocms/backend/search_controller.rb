module Geocms
  module Backend
    class SearchController < Geocms::Backend::ApplicationController
     #load_and_authorize_resource class: "Geocms::Search"

      rescue_from CanCan::AccessDenied do |exception|
        controle_access(exception)
      end

      def search
        @layers = Geocms::Layer.joins(:categories).where("geocms_categories.account_id= ?",current_tenant.id).search(params[:query]).page(params[:page])
        respond_with @layers.to_a.uniq
      end

    end
  end
end
