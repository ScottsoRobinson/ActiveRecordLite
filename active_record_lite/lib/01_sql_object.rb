require_relative 'db_connection'
require 'active_support/inflector'
# NB: the attr_accessor we wrote in phase 0 is NOT used in the rest
# of this project. It was only a warm up.

class SQLObject

  def self.columns

    cols = DBConnection.execute2(<<-SQL)
      SELECT
        *
      FROM
        "#{self.table_name}"
    SQL

    cols[0].map(&:to_sym)
  end

  def self.finalize!
    self.columns.each do |column|

      col = column.to_s

      define_method(col+"=") do |arg|
        self.attributes[column] = arg
      end

      define_method(col) do
        self.attributes[column]
      end
    end
  end

  def self.table_name=(table_name)
    @table_name = table_name

  end

  def self.table_name
    @table_name ||= self.to_s.tableize

  end

  def self.all
    collection = DBConnection.execute(<<-SQL)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
    SQL


    self.parse_all(collection)
  end

  def self.parse_all(results)
    array = []
    results.each do |result|
      array << self.new(result)
    end
    array
  end

  def self.find(id)
    single_item = DBConnection.execute(<<-SQL, id)
      SELECT
        #{self.table_name}.*
      FROM
        #{self.table_name}
      WHERE
        id = ?
    SQL
    return nil if single_item.empty?
<<<<<<< HEAD
    parse_all(single_item).first
=======
    self.new(single_item[0])
>>>>>>> 407a7d3b36bfcbcb3f50884eb85d8fc59f7c9b58
  end

  def initialize(params = {})

    params.each do |param, val|
<<<<<<< HEAD
      if self.class.columns.include?(param.to_sym)
        self.send("#{param.to_s}=", val)
      else
        raise StandardError.new "unknown attribute '#{param}'"
      end

      #self.send("#{param.to_s}=", val)
=======
      unless self.class.columns.include?(param.to_sym)
        raise StandardError.new "unknown attribute '#{param}'"
      end

      self.send("#{param.to_s}=", val)
>>>>>>> 407a7d3b36bfcbcb3f50884eb85d8fc59f7c9b58

    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
<<<<<<< HEAD

=======
  
>>>>>>> 407a7d3b36bfcbcb3f50884eb85d8fc59f7c9b58
    self.attributes.values
  end

  def insert
    col_names = self.class.columns[1..-1].join(",")

    n = attribute_values.length

    question_marks = (["?"] * n).join(",")

    DBConnection.execute(<<-SQL, *attribute_values)
      INSERT INTO
        #{self.class.to_s.tableize} (#{col_names})
      VALUES
        (#{question_marks})
    SQL
    id = DBConnection.last_insert_row_id
    self.id = id

  end

  def update
    col_names = self.class.columns
    col_names_string = col_names.map{|el| "#{el} = ?"}.join(",")

    DBConnection.execute(<<-SQL, self.attribute_values, id)
      UPDATE
      #{self.class.table_name}
      SET
      #{col_names_string}
      WHERE
        id = ?
    SQL
  end

  def save
    if self.id.nil?
      insert
    else
      update
    end
  end
end
