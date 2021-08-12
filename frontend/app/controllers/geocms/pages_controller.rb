require_dependency "geocms/application_controller"

module Geocms
  class PagesController < ApplicationController
    before_action :controle_access
    after_action :allow_iframe

    def controle_access
      if (current_user.blank? && @current_tenant.private)
        Rails.logger.debug "Access denied on instance for non logged in user."
        redirect_to login_url, :alert => t('session.unauthorized')
      end
    end

    def allow_iframe
      response.headers.except! 'X-Frame-Options'
    end

    def index
    end
  end
end
