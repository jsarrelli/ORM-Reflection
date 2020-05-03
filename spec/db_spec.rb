require 'tadb'
require 'model/person'

describe 'DB' do
  let(:db) { TADB::DB.table('a_temporary_table') }
  let(:a_person) { {first_name: "pepe", last_name: 'grillo', age: 20} }
  let(:another_person) { {first_name: "pipo", last_name: 'pescador', age: 30} }

  before do
    TADB::DB::clear_all
  end

  after do
    TADB::DB::clear_all
  end


  describe 'an empty DB' do
    it 'should have an entry after an insert' do
      db.insert(a_person)
      expect(db.entries.size).to be 1
    end

    it 'should have two entries after two inserts' do
      db.insert(a_person)
      db.insert(another_person)
      expect(db.entries.size).to be 2
    end

    it 'should contain the inserted entry' do
      a_person_id = db.insert(a_person)
      entry_found = db.entries.find { |entry| entry[:id] == a_person_id }
      expect(entry_found[:id]).to eq a_person_id
    end

    it 'should be empty after delete the inserted entry' do
      a_person_id = db.insert(a_person)
      db.delete(a_person_id)
      expect(db.entries.empty?).to be true
    end

    it 'could not be found after being deleted' do
      a_person_id = db.insert(a_person)
      db.insert(another_person)
      db.delete(a_person_id)
      entry_found = db.entries.find { |entry| entry[:id] == a_person_id }
      expect(entry_found.nil?).to be true
    end

  end
end
