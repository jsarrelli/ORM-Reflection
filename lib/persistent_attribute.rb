class PersistentAttribute
  attr_accessor :type
  attr_accessor :attribute_name
  attr_accessor :validators
  attr_accessor :default

  def initialize(type, named, validators, default)
    @type = type
    @attribute_name = named
    @validators = validators
    @default = default
  end

  def persistible?
    type.include?(Persistible)
  end

  def validate(value)
    validators.each { |validator| validator.validate(value) }
  end

end