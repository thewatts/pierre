require "pierre/version"
require "pierre/configuration"
require "pierre/i18n_adapter"
require "pierre/store"

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

  def self.i18n_adapter
    @i18n_adapter ||= Pierre::I18nAdapter.new(store)
  end

  def self.import(file = nil)
    store.import(file)
  end

  def self.keys(lang)
    store.keys(lang)
  end

  def self.languages
    store.languages
  end

  def self.manage(lang, options = {})
    options[:reference] ||= :en
    store.manage(lang, options)
  end

  def self.remove(key)
    store.remove(key)
  end

  def self.set(lang, key, text, options = {})
    store.set(lang, key, text, options)
  end

  def self.store
    @store ||= configuration.store
  end
end
