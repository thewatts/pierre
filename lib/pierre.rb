require "pierre/configuration"
require "pierre/store"
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

  def self.dump(lang)
    store.dump(lang)
  end

  def self.get(lang, key, options = { fallback: true })
    store.get(lang, key, options)
  end

  def self.keys(lang)
    store.keys(lang)
  end

  def self.manage(lang, options = {})
    options[:reference] ||= :en
    store.manage(lang, options)
  end

  def self.set(lang, key, text, options = {})
    store.set(lang, key, text, options)
  end

  def self.store
    @store ||= configuration.store
  end
end
