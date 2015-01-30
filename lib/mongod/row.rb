require 'bson'

module Mongod
  class Row

    def initialize(bson)
      p "bson: #{bson.inspect}"
      self.class_eval %Q{
        attr_accessor *#{bson.keys}
      }
      bson.each do |k, v|
        instance_eval %Q{ self.#{k.to_s} = set_value(v) }
      end
    end

    def set_value(value)
      case value.class.to_s
      when 'String'
        "#{value}"
      when 'Fixnum', 'BSON::ObjectId', 'Time', 'Float'
        value
      else
        Rails.logger.debug("Mongod::Row.set_value: Unknown type, #{value} => #{value.class.to_s}")
        value
      end
    end

  end
end
