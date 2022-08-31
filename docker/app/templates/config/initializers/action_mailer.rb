Rails.application.configure do
  config.action_mailer.default_url_options = {
    host: ENV.fetch("EMAIL_HOST", "")
  }
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address: ENV.fetch("SMTP_ADDRESS", ""),
    port: ENV.fetch("SMTP_PORT", ""),
    domain: ENV.fetch("SMTP_DOMAIN", ""),
    user_name: ENV.fetch("SMTP_USER", ""),
    password: ENV.fetch("SMTP_PASSWORD", ""),
    authentication: "login",
    enable_starttls_auto: true
  }
end
