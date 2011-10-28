#require 'Rails'

module Less::Js::Routes
  class Railtie < ::Rails::Railtie
    rake_tasks do
      load File.dirname(__FILE__) + '/../tasks/less_js_routes.tasks'
    end
  end
end