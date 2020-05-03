require 'persistent_attribute'

class OnePersistentAttribute < PersistentAttribute

  def initialize(type, named, validators, default)
    super(type, named, validators, default)
  end

  def persist(owner)
    attribute_to_persist = owner.send(attribute_name)
    attribute_to_persist = default if attribute_to_persist.nil? && !default.nil?
    validate(attribute_to_persist)
    persistible? && !attribute_to_persist.nil? ? attribute_to_persist.save! : attribute_to_persist
  end

  def get(value, owner)
    persistible? && !value.nil? ? type.send(:search_by_id, value).at(0) : value
  end

  def delete(owner)
    value = owner.send(attribute_name)
    value.forget! if persistible? && !value.nil?
  end

end