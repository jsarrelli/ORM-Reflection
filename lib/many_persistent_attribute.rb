require 'persistent_attribute'
class ManyPersistentAttribute < PersistentAttribute

  def initialize(type, named, validators, default)
    super(type, named, validators, default)
  end

  def persist(owner)
    many_attribute = owner.send(attribute_name)
    many_attribute = default if many_attribute.nil? && !default.nil?
    unless (many_attribute.nil?)
      many_attribute.each do |attribute|
        relational_table = TADB::DB.table("#{owner.class}_#{attribute.class}")

        if persistible?
          relational_entry = {"id_#{owner.class}": owner.id, "id_#{attribute.class}": attribute.save!}
        else
          relational_entry = {"id_#{owner.class}": owner.id, "#{attribute.class}": attribute}
        end
        relational_table.insert(relational_entry)
      end
    end
  end

  def get(_, owner)
    relational_table = TADB::DB.table("#{owner.class}_#{type}")
    relational_table.entries
        .select { |entry| entry[:"id_#{owner.class}"].eql?(owner.id) }
        .flat_map { |entry| type.search_by_id(entry[:"id_#{type}"]) }
  end

  def delete(owner)
    value = owner.send(attribute_name)
    value.each do |element|
      relational_table = TADB::DB.table("#{owner.class}_#{element.class}")
      relational_table.entries
          .filter { |entry| entry[:"id_#{owner.class}"].eql? owner.id }
          .each { |entry| relational_table.delete(entry[:id]) }
    end
  end


end