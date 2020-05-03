describe 'Persistible' do

  let(:julian) {
    person = Person.new
    person.first_name = 'juli'
    person.last_name = 'sarrelli'
    person.age = 21
    person
  }

  let(:pepe) {
    person = Person.new
    person.first_name = 'pepe'
    person.last_name = 'grillo'
    person.age = 21
    person
  }

  let(:grade) {
    grade = Grade.new
    grade.value = 5
    grade
  }

  let(:professor) {
    professor = Professor.new
    professor.first_name = 'guille'
    professor.last_name = 'morzan'
    professor.age = 45
    professor
  }

  let(:maths) {
    subject = Subject.new
    subject.name = 'Maths'
    subject
  }

  let(:person_table) { TADB::DB.table(Person) }
  let(:professor_table) { TADB::DB.table(Professor) }
  let(:subject_table) { TADB::DB.table(Subject) }
  let(:grade_table) { TADB::DB.table(Grade) }

  before do
    TADB::DB.clear_all
  end

  after do
    TADB::DB.clear_all
  end

  it 'Save' do
    julian.grade = grade
    julian.save!
    entry_found = person_table.entries.find { |entry| entry[:id] == julian.id }
    expect(entry_found[:first_name]).to eq 'juli'
  end

  it 'Save entity with null fields' do
    julian.save!
    entry_found = person_table.entries.find { |entry| entry[:id] == julian.id }
    expect(entry_found[:first_name]).to eq 'juli'
  end

  it 'Save entity with has_many' do
    professor.subjects = [maths]
    professor.save!
    person_found = professor_table.entries.find { |entry| entry[:id] == professor.id }
    expect(person_found[:first_name]).to eq professor.first_name

    subject_found = subject_table.entries.find { |entry| entry[:id] == maths.id }
    expect(subject_found[:name]).to eq maths.name

  end
  it 'Delete' do
    julian.grade = grade
    julian.save!

    entry_found = person_table.entries.find { |entry| entry[:id] == julian.id }
    expect(entry_found[:first_name]).to eq 'juli'
    julian.forget!
    entry_found = person_table.entries.find { |entry| entry[:id] == julian.id }
    expect(entry_found.nil?).to be true
    expect(grade_table.entries.empty?).to be true

  end

  it 'Delete entity with null fields' do
    julian.save!
    entry_found = person_table.entries.find { |entry| entry[:id] == julian.id }
    expect(entry_found[:first_name]).to eq 'juli'
    julian.forget!
    entry_found = person_table.entries.find { |entry| entry[:id] == julian.id }
    expect(entry_found.nil?).to be true

  end

  it 'Delete entity with has_many' do
    relational_table = TADB::DB.table('Professor_Subject')

    professor.subjects = [maths]
    professor.save!
    expect(professor_table.entries.size).to eq 1
    expect(subject_table.entries.size).to eq 1
    expect(relational_table.entries.size).to eq 1


    professor.forget!
    expect(professor_table.entries.size).to eq 0
    expect(subject_table.entries.size).to eq 1
    expect(relational_table.entries.size).to eq 0
  end


  it 'Refresh' do
    julian.grade = grade
    julian.save!
    expect(julian.first_name).to eq 'juli'
    expect(julian.grade.value).to eq 5

    julian.first_name = 'pepe'
    grade.value = 7
    expect(julian.first_name).to eq 'pepe'
    expect(julian.grade.value).to eq 7

    julian.refresh!
    expect(julian.first_name).to eq 'juli'
    expect(julian.grade.value).to eq 5
  end

  it 'Refresh with has_many' do
    professor.subjects = [maths]
    expect(professor.subjects.at(0).name).to eq 'Maths'
    professor.save!

    maths.name = 'Chemistry'
    expect(professor.subjects.at(0).name).to eq 'Chemistry'

    professor.refresh!
    expect(professor.subjects.at(0).name).to eq 'Maths'
  end

  it 'allInstances' do
    julian.save!
    pepe.save!
    expect(Person.all_instances.size).to eq 2
  end


  it 'allInstances with descendants' do
    julian.save!
    pepe.save!

    professor = Professor.new
    professor.first_name = 'gas'
    professor.last_name = 'schabas'
    professor.age = 25
    professor.subjects = [maths]
    professor.save!

    expect(Person.all_instances.size).to eq 3
  end

  it 'search_by' do
    julian.save!
    pepe.save!
    person_found = Person.search_by_first_name('juli')
    expect(person_found.at(0).last_name).to eq 'sarrelli'
  end

  it 'search_by with descendants' do
    julian.save!
    pepe.save!
    professor.subjects = [maths]
    professor.save!

    person_found = Person.search_by_first_name('guille')
    expect(person_found.at(0).last_name).to eq 'morzan'
  end

  it 'search_by has_many attribute' do
    julian.save!
    pepe.save!
    professor.subjects = [maths]
    professor.save!
    person_found = Professor.search_by_first_name('guille')
    expect(person_found.at(0).last_name).to eq 'morzan'
    expect(person_found.at(0).subjects.at(0).id).to eq maths.id
  end

  it('type validation should pass if all attributes are valid') do
    expect { julian.validate! }.to_not raise_error
  end

  it('type validation should throw exception if some attribute is not valid') do
    professor.subjects = [maths, grade]
    expect { professor.validate! }.to raise_error(RuntimeError)
  end

  it('from validation should throw exception if age is < 18 when try to save') do
    julian.age = 17
    expect { julian.save! }.to raise_error(RuntimeError)
  end

  it('to validation should throw exception if age is > 50 when try to save') do
    julian.age = 51
    expect { julian.save! }.to raise_error(RuntimeError)
  end

  it('no_blank validation should throw exception if age is nil') do
    julian.age = nil
    expect { julian.save! }.to raise_error(RuntimeError)
  end

  it('proc validation should throw exception if grade < 2') do
    julian.age = nil
    julian.grade = 1
    expect { julian.save! }.to raise_error(RuntimeError)
  end

  it('save a person with out a last name, should use the default') do
    person = Person.new
    person.first_name = 'juli'
    person.age = 21
    person
    expect(person.last_name).to eq("Papurri")
  end

  it('if we try to save a person with nil attribute that has a default should save it with the default') do
    julian.last_name = nil
    julian.save!
    julian.refresh!
    expect(julian.last_name).to eq("Papurri")
  end

  it('override default attribute') do
    person = Person.new
    person.first_name = 'juli'
    person.last_name = 'pepe'
    person.age = 21
    person
    expect(person.last_name).to eq("pepe")
  end

  it('refresh an object with default attributes should override existing one') do
    person = Person.new
    person.first_name = 'juli'
    person.age = 21
    person.save!
    expect(person.last_name).to eq("Papurri")
    person.refresh!
    expect(person.last_name).to eq("Papurri")
  end
end