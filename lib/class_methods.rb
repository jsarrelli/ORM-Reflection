require 'tadb'
require 'validators/from_number_validator'
require 'validators/to_number_validator'
require 'validators/no_blank_validator'
require 'validators/proc_validator'
require 'validators/type_validator'

module ClassMethods

  def attributes_to_persist
    @attributes_to_persist ||= {}
    if superclass.respond_to?(:attributes_to_persist)
      @attributes_to_persist.merge!(superclass.attributes_to_persist)
    else
      @attributes_to_persist
    end
  end

  def has_one(data_type, named: raise('can not be empty'), no_blank: false, from: nil, to: nil, default: nil, validate: nil)
    attr_accessor named
    validators = generate_validators(data_type, no_blank, from, to, validate)
    attributes_to_persist[named] = OnePersistentAttribute.new(data_type, named, validators, default)
  end

  def has_many(data_type, named: raise('can not be empty'), no_blank: false, from: nil, to: nil, default: nil, validate: nil)
    attr_accessor named
    validators = generate_validators(data_type, no_blank, from, to, validate)
    attributes_to_persist[named] = ManyPersistentAttribute.new(data_type, named, validators, default)
  end

  def generate_validators(type, no_blank, from, to, validate)
    validators = []
    validators.push(TypeValidator.new(type))
    validators.push(NoBlankValidator.new) if no_blank
    validators.push(FromNumberValidator.new(from)) unless from.nil?
    validators.push(ToNumberValidator.new(to)) unless to.nil?
    validators.push(ProcValidator.new(validate)) unless validate.nil?
    validators
  end

  def all_instances
    descendants = ObjectSpace.each_object(Class).select { |klass| klass <= self }
    descendants.flat_map do |klass|
      table = TADB::DB.table(klass)

      table.entries.map do |entry|
        object = klass.new
        klass.attributes_to_persist.each do |key, persistent_attribute|
          value_found = persistent_attribute.get(entry[key], object)
          object.instance_variable_set("@#{key}", value_found)
        end
        object
      end
    end
  end

  def method_missing(method, *args, &block)
    if method.to_s.start_with?('search_by_')
      value_to_find = args.at(0)
      by_attribute = method.to_s.delete_prefix!('search_by_')
      all_instances.select do |object|
        object.instance_variable_get("@#{by_attribute}").eql?(value_to_find)
      end
    else
      super
    end
  end

  def respond_to_missing?(sym, _priv = false)
    sym.to_s.start_with?('search_by_')
  end

end

