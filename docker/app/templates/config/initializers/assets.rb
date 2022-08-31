Rails.application.config.assets.version = '1.0'

Rails.application.config.assets.precompile += %w( geocms/backend/backend.css )
Rails.application.config.assets.precompile += %w( geocms/backend.js )
Rails.application.config.assets.precompile += %w( ckeditor/* )
