module Geocms
  module Backend
    class Engine < ::Rails::Engine
      isolate_namespace Geocms
      engine_name "geocms_backend"
      config.to_prepare do
        Rails.application.config.assets.precompile += %w(
          geocms/backend/backend.css
          geocms/backend.js
          ckeditor/lang/fr.js
		  geocms/expand-button.png
          typeahead/typeahead.js
        )
      end
    end
  end
end
