namespace :maconf do
  require "geocms"

  desc "Création des comptes utilisateurs"
  task create_first_accounts: :environment do
    Geocms::Role.find_or_create_by!(name: "admin_instance")
    Geocms::Role.find_or_create_by!(name: "admin_data")
    Geocms::Role.find_or_create_by!(name: "user")

    a = Geocms::Account.new
    a.name = ENV.fetch("GEOCMS_SITE")
    a.default = true
    a.subdomain = ENV.fetch("GEOCMS_SUBDOMAIN")
    a.save

    u = Geocms::User.new
    u.username = ENV.fetch("GEOCMS_ADMIN_USER")
    u.email = ENV.fetch("GEOCMS_ADMIN_EMAIL")
    u.password = ENV.fetch("GEOCMS_ADMIN_PASSWORD")
    u.first_name = ENV.fetch("GEOCMS_ADMIN_FIRST_NAME")
    u.last_name = ENV.fetch("GEOCMS_ADMIN_LAST_NAME")
    u.accounts << a
    u.add_role "admin"
    u.add_role "admin_instance"
    u.add_role "admin_data"
    u.add_role "user"
    u.save

    u = Geocms::User.new
    u.username = ENV.fetch("GEOCMS_INSTANCE_ADMIN_USER")
    u.email = ENV.fetch("GEOCMS_INSTANCE_ADMIN_EMAIL")
    u.password = ENV.fetch("GEOCMS_INSTANCE_ADMIN_PASSWORD")
    u.first_name = ENV.fetch("GEOCMS_INSTANCE_ADMIN_FIRST_NAME")
    u.last_name = ENV.fetch("GEOCMS_INSTANCE_ADMIN_LAST_NAME")
    u.accounts << a
    u.add_role "admin_data"
    u.add_role "admin_instance"
    u.save
  end
end
