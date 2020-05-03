class FromNumberValidator
  attr_accessor :min

  def initialize(min)
    @min = min
  end

  def validate(value)
    raise("Validation exception: #{value}<#{min}") if value < min
  end
end