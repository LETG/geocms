#encoding: UTF-8
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
version = File.read(File.expand_path("../../GEOCMS_VERSION", __FILE__)).strip

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "geocms_core"
  s.version     = version
  s.authors     = ["Philippe HUET", "Jérôme CHAPRON", "dotgee"]
  s.email       = ["philippe@dotgee.fr", "jchapron@dotgee.fr", "contact@dotgee.fr"]
  s.homepage    = "http://mapsonic.dotgeeapp.com/"
  s.summary     = "Core components to handle geospatial data from gis web servers"
  s.description = "Core components to handle geospatial data from gis web servers"
  s.license     = "CECILL"

  s.files = Dir["{app,config,db,lib}/**/*", "CECILL-LICENSE", "Rakefile", "README.rdoc"]
  s.require_path = 'lib'
  s.test_files = Dir["test/**/*"]

  s.add_dependency "rails", ">= 6.0.3.2"
  # s.add_dependency "sprockets", "~> 2.11.0"
  s.add_dependency "compass-rails"
  s.add_dependency "font-awesome-sass", "4.7"
  s.add_dependency "bootstrap-sass", "3.3.7"
  s.add_dependency 'draper'
  s.add_dependency "acts_as_tenant", '~> 0.3.6'
  s.add_dependency "friendly_id"
  s.add_dependency "ancestry"
  s.add_dependency "acts_as_list", "~> 1.0.0"
  s.add_dependency 'mini_magick'
  s.add_dependency 'carrierwave', '~> 0.10.0'
  s.add_dependency "cancancan"
  s.add_dependency "rolify"
  s.add_dependency "rgeo"
  s.add_dependency "rgeo-proj4"
  s.add_dependency "curb"
  s.add_dependency "pg_search"
  s.add_dependency "sorcery"
  s.add_dependency "kaminari"
  s.add_dependency "sidekiq"
  s.add_dependency "interactor", "~> 3.0"

end
