class NoBlankValidator
  def validate(value)
    raise('No Blank validation exception on value') if value.nil?
  end
end