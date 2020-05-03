require 'tadb'
require 'one_persistent_attribute'
require 'many_persistent_attribute'
require 'class_methods'

module Persistible

  def self.included(base)
    super
    puts "#{base} incluyo a #{self} "
    base.extend(ClassMethods)
    base.has_one String, named: :id
    base.singleton_class.send(:define_method, :included) do |klass|
      klass.extend(ClassMethods)
    end

    def base.new(*args)
      object = super(*args)
      attributes_to_persist.each do |key, persistent_attribute|
        object.instance_variable_set("@#{key}", persistent_attribute.default) unless persistent_attribute.default.nil?
      end
      object
    end
  end


  def save!
    table = TADB::DB.table(self.class)
    attributes = {}
    # primero persistimos todos los objetos simples y los has_one
    self.class.attributes_to_persist
        .select { |key, klass| klass.class.equal?(OnePersistentAttribute) }
        .each { |key, klass| attributes[key] = klass.persist(self) }
    attributes.filter! { |_, attribute| !attribute.nil? }

    @id = table.insert(attributes)

    # despues persistimos los has_many
    self.class.attributes_to_persist
        .select { |_, klass| klass.class.equal?(ManyPersistentAttribute) }
        .each { |_, klass| klass.persist(self) }
    id
  end

  def refresh!
    persisted_object = self.class.search_by_id(id).at(0)

    persisted_object.instance_variables.each do |symbol|
      persisted_value = persisted_object.instance_variable_get(symbol)
      instance_variable_set(symbol, persisted_value)
    end
  end

  def forget!
    table = TADB::DB.table(self.class)
    self.class.attributes_to_persist.each do |_, persistent_attribute|
      persistent_attribute.delete(self)
    end
    table.delete(id)
    self.id = nil
  end

  def validate!
    self.class.attributes_to_persist.each do |key, persistent_attribute|
      persistent_attribute.validate(send(key))
    end
  end

end