require 'active_support/configurable'

module Less::Js::Routes::Config
  
  def self.configure(&block)
    yield @config ||= Less::Js::Routes::Config::Configuration.new
  end

  def self.config
    @config
  end

  # need a Class for 3.0
  class Configuration #:nodoc:
    include ActiveSupport::Configurable
    config_accessor :debug
    config_accessor :ignore
    config_accessor :only
    config_accessor :output_path
    config_accessor :internal_debug
  end

  configure do |config|
    config.debug = false
    config.internal_debug = false
    config.ignore = []
    config.only = []
    config.output_path = "#{Rails.public_path}/javascripts/less_routes.js"
  end
end
