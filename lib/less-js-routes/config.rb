require 'active_support/configurable'

module Less::JS::Routes
  
  def self.configure(&block)
    yield @config ||= Less::Js::Routes::Configuration.new
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
  end

  configure do |config|
    config.debug = false
    config.ignore = []
    config.only = []
  end
end
