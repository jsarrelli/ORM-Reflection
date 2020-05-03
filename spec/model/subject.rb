class Subject
  include Persistible
  has_one String, named: :name
end