module Traco
  def self.translates(klass, *columns)
    klass.instance_eval do

      @translates_columns ||= []
      @translates_columns |= columns.map(&:to_sym)

      extend Traco::ClassMethods
      include Traco::InstanceMethods

      columns.each do |column|
        define_method(column) do
          read_localized_value(column)
        end

        define_method("#{column}=") do |value|
          write_localized_value(column, value)
        end
      end

    end
  end
end
