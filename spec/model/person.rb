require_relative '../../lib/persistible'
require_relative 'grade'

class Person
  include Persistible
  has_one String, named: :first_name
  has_one String, named: :last_name, default: 'Papurri'
  has_one Numeric, named: :age, no_blank: true, from: 18, to: 50
  has_one Grade, named: :grade, validate: proc { |grade| grade.value > 2 }

  attr_accessor :some_other_non_persistible_attribute
end
