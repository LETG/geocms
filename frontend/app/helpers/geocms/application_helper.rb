module Geocms
  module ApplicationHelper
    def logo_for_tenant(tenant = current_tenant)
      url = (tenant && tenant.logo?) ? tenant.logo.url : "dotgeocms.png"
      image_tag url
    end
  end
end
