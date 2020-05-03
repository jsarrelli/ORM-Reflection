class ProcValidator
  attr_accessor :function

  def initialize(function)
    @function = function
  end

  def validate(value)
    unless value.nil?
      if value.class.equal?(Array)
        raise('Proc validation exception') unless value.all? { |each_value| function.call(each_value) }
      else
        raise('Proc validation exception') unless function.call(value)
      end
    end
  end

end