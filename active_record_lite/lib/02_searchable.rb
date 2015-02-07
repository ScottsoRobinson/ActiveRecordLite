require_relative 'db_connection'
require_relative '01_sql_object'

module Searchable
  def where(params)
    keys = params.keys
    values_ = params.values
    where_string = keys.map{|key| "#{key} = ?"}.join(" AND ")
    #values_ = values[0] if values.length == 1
    items = DBConnection.execute(<<-SQL, values_)
      SELECT
        *
      FROM
        #{self.table_name}
      WHERE
        #{where_string}
    SQL
    items.map{|item| self.new(item)}
  end
end

class SQLObject
  extend Searchable
end
