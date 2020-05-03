require_relative 'subject'
class Professor < Person
  has_many Subject, named: :subjects
end