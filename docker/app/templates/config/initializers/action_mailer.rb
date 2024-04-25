Rails.application.configure do
  config.action_mailer.default_url_options = {
    host: ENV.fetch("EMAIL_HOST", "")
  }
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", ""),
    port: ENV.fetch("SMTP_PORT", ""),
    domain: ENV.fetch("SMTP_DOMAIN", ""),
    user_name: ENV.fetch("SMTP_USER", "").present? ? ENV.fetch("SMTP_USER") : nil,
    password: ENV.fetch("SMTP_PASSWORD", "").present? ? ENV.fetch("SMTP_PASSWORD") : nil,
    authentication: ENV.fetch("SMTP_AUTHENTICATION", "").present? ? ENV.fetch("SMTP_AUTHENTICATION") : nil,
    enable_starttls_auto: ActiveModel::Type::Boolean.new.cast(ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", "")),
    ssl: ActiveModel::Type::Boolean.new.cast(ENV.fetch("SMTP_SSL", "")),
    tls: ActiveModel::Type::Boolean.new.cast(ENV.fetch("SMTP_TLS", "")),
  }
end
