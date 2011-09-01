# -*- encoding: utf-8 -*-
require File.expand_path('../lib/less-js-routes/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["stevenbristol"]
  gem.email         = ["stevenbristol@gmail.com"]
  gem.description   = "Named routes in your javascript"
  gem.summary       = "Named routes in your javascript!"
  gem.homepage      = "http://lesseverything.com"

  #gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  #gem.files         = Dir['lib/**/*.rb'] + Dir['lib/tasks/*'] 
  gem.files         = [
                        "lib/less-js-routes/config.rb", 
                        "lib/less-js-routes/less-js-routes.rb", 
                        "lib/less-js-routes/version.rb", 
                        "lib/less-js-routes.rb", 
                        "lib/railtie.rb",
                        "lib/tasks/less_js_routes.tasks"
                      ] 
  #gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "less-js-routes"
  gem.require_paths = ["lib"]
  gem.version       = Less::Js::Routes::VERSION
end
