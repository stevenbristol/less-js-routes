# -*- encoding: utf-8 -*-
require File.expand_path('../lib/less-js-routes/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["stevenbristol"]
  gem.email         = ["stevenbristol@gmail.com"]
  gem.description   = "Named routes in your javascript"
  gem.summary       = "Named routes in your javascript"
  gem.homepage      = ""

  #gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = "less-js-routes"
  gem.require_paths = ["lib"]
  gem.version       = Less::Js::Routes::VERSION
end
