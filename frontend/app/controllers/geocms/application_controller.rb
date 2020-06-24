module Geocms
  class ApplicationController < ActionController::Base

    set_current_tenant_by_subdomain(Geocms::Account, :subdomain)

    respond_to :html
    protect_from_forgery
    layout 'geocms/layouts/geocms_application'

    before_action :decorate_tenant
    before_action :set_locale

    private
      def decorate_tenant
	if !current_tenant.nil?        
          @current_tenant = current_tenant.decorate
        end
      end

      def set_locale
        session[:locale] = params[:locale] if params[:locale]
        session[:locale] ||= :fr
        I18n.locale = session[:locale]
      end
    #   def not_authenticated
    #     redirect_to login_url, :alert => "First log in to view this page."
    #   end

    #   def current_ability
    #     @current_ability ||= Ability.new(current_user, current_tenant)
    #   end

    #   rescue_from CanCan::AccessDenied do |exception|
    #     Rails.logger.debug "Access denied on #{exception.action} #{exception.subject.inspect}"
    #     #redirect_to root_url, :alert => t("access_denied")
    #   end
  end
end
