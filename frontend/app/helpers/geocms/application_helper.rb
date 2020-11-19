module Geocms
  module ApplicationHelper
    def logo_for_tenant(tenant = current_tenant)
      	url = (tenant && tenant.logo?) ? tenant.logo.url : "geocms/dotgeocms.png"
      	image_tag url
    end

    def logo_url_for_tenant(tenant = current_tenant) 
   	 	url = (tenant && tenant.logo?) ? tenant.logo.url : "geocms/dotgeocms.png"
	end
  end
end
