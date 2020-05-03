require 'persistible'
class Grade
  include Persistible
  has_one Numeric, named: :value # Pero ahora es Numeric
end
