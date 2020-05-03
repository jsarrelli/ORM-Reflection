class ToNumberValidator
  attr_accessor :max

  def initialize(max)
    @max = max
  end

  def validate(value)
    raise("Validation exception: #{value}>#{max}") if value > max
  end
end