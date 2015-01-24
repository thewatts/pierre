require "pierre/configuration"
require "pierre/version"

module Pierre
  class << self
    attr_writer :configuration
  end

  def self.configuration
    @configuration ||= Configuration.new
  end

  def self.configure
    yield(configuration)
  end

  def self.get(lang, key)
    store.get(lang, key)
  end

  def self.set(lang, key, text, options = {})
    store.set(lang, key, text, options)
  end

  def self.store
    @store ||= configuration.store
  end
end
