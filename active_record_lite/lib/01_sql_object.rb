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
    # ...
  end

  def self.parse_all(results)
    # ...
  end

  def self.find(id)
    # ...
  end

  def initialize(params = {})

    params.each do |param, val|
      unless self.class.columns.include?(param.to_sym)
        raise StandardError.new "unknown attribute '#{param}'"
      end

      self.send("#{param.to_s}=", val)

    end
  end

  def attributes
    @attributes ||= {}
  end

  def attribute_values
    self.attributes.values
  end

  def insert
    # ...
  end

  def update
    # ...
  end

  def save
    # ...
  end
end
