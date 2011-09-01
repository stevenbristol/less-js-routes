
namespace :less do
  namespace :js do
    desc "Make a js file that will have functions that will return restful routes/urls."
    task :routes => :environment do
      require File.join(File.dirname(__FILE__), "../less/js_routes.rb")
      
      # Hack for actually load the routes (taken from railties console/app.rb)
      ActionDispatch::Callbacks.new(lambda {}, false)
      
      Less::JsRoutes.generate!
    end
  end
end