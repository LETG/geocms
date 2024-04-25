Rails.application.routes.draw do
  mount Geocms::Core::Engine, :at => '/'
end
