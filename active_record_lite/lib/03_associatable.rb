require_relative '02_searchable'
require 'active_support/inflector'

# Phase IIIa
class AssocOptions
  attr_accessor(
    :foreign_key,
    :class_name,
    :primary_key
  )

  def model_class
    @class_name.constantize
  end

  def table_name
    @class_name.underscore + "s"
  end
end

class BelongsToOptions < AssocOptions
  def initialize(name, options = {})
    defaults = {
      :class_name => name.to_s.capitalize,
      :foreign_key => "#{name}_id".to_sym,
      :primary_key => :id
    }

    options = defaults.merge(options)

    @class_name = options[:class_name]
    @foreign_key = options[:foreign_key]
    @primary_key = options[:primary_key]
  end
end

class HasManyOptions < AssocOptions
  def initialize(name, self_class_name, options = {})

    defaults = {
      :class_name => name.to_s.singularize.camelcase,
      :foreign_key => (self_class_name.to_s.underscore + "_id").to_sym,
      :primary_key => :id
    }
    options = defaults.merge(options)
    @primary_key = options[:primary_key]
    @foreign_key = options[:foreign_key]
    @class_name = options[:class_name]
  end
end

module Associatable
  # Phase IIIb
  def belongs_to(name, options = {})
    options = BelongsToOptions.new(name, options)

    define_method(name) do
      foreign = options.foreign_key
      classname = options.model_class
      primary = options.primary_key
      classname.where(primary.to_sym => self.send(foreign)).first

    end
  end

  def has_many(name, options = {})
     options = HasManyOptions.new(name, self.name, options)

    define_method(name) do
      foreign = options.foreign_key
      classname = options.model_class
      primary = options.primary_key
      classname.where(foreign.to_sym => self.send(primary))

    end
  end

  def assoc_options
    # Wait to implement this in Phase IVa. Modify `belongs_to`, too.
  end
end

class SQLObject
  extend Associatable
end
