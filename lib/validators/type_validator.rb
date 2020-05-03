class TypeValidator
  attr_accessor :type

  def initialize(type)
    @type = type
  end

  def validate(value)
    if !value.nil? &&
       (!value.class.ancestors.include?(type) ||
           (value.class.equal?(ManyPersistentAttribute) && !value.all? { |element| element.class.eql?(type) }))
      raise("Validation exception: #{value}:#{value.class} is not a #{type}")
    end
  end

end