#encoding: UTF-8
$:.push File.expand_path("../lib", __FILE__)

# Maintain your gem's version:
version = File.read(File.expand_path("../../GEOCMS_VERSION", __FILE__)).strip

# Describe your gem and declare its dependencies:
Gem::Specification.new do |s|
  s.name        = "geocms_frontend"
  s.version     = version
  s.authors     = ["Philippe HUET", "Jérôme CHAPRON", "dotgee"]
  s.email       = ["philippe@dotgee.fr", "jchapron@dotgee.fr", "contact@dotgee.fr"]
  s.homepage    = "http://mapsonic.dotgeeapp.com"
  s.summary     = "Geocms'frontend"
  s.description = "Geocms'frontend"
  s.license     = "CECILL"

  s.files        = Dir["{app,config,db,lib}/**/*", "CECILL-LICENSE", "Rakefile", "README.rdoc"]
  s.test_files   = Dir["test/**/*"]
  #s.files        = `git ls-files`.split("\n")
  #s.test_files   = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.require_path = 'lib'
  s.requirements << 'none'

  s.add_dependency 'geocms_core', version
  s.add_dependency 'geocms_api', version

  s.add_dependency "sass-rails"
  s.add_dependency "coffee-rails"
  s.add_dependency "slim-rails"

  s.add_dependency 'rails-assets-jquery', "> 2.0.0"
  s.add_dependency 'rails-assets-lodash', "2.4.1"
  s.add_dependency 'rails-assets-angularjs', "1.3.20"
  s.add_dependency 'rails-assets-bootstrap', "3.3.7"

  s.add_dependency 'rails-assets-restangular'
  s.add_dependency 'rails-assets-angular-ui-router', "0.2.10"
  s.add_dependency 'rails-assets-angular-animate'
  s.add_dependency 'rails-assets-angular-sanitize'
  s.add_dependency 'rails-assets-angular-bootstrap', '0.14.3'
  # s.add_dependency 'rails-assets-angular-ui-slider', '0.0.2'
  s.add_dependency 'rails-assets-masonry', '3.1.5'
  s.add_dependency 'rails-assets-angular-masonry'
  s.add_dependency 'rails-assets-leaflet', "0.7.3"
  s.add_dependency 'rails-assets-proj4', "~> 1.3.4"
  # Waiting for proj4leaflet to be compatible
  # s.add_dependency 'rails-assets-proj4leaflet', "0.7.0"
  s.add_dependency 'rails-assets-moment', "2.7.0"
  s.add_dependency 'rails-assets-angular-summernote'
  s.add_dependency 'rails-assets-font-awsome', "4.7"
  s.add_dependency 'rails-assets-summernote'
end
