module ActiveAdminImport
  class Model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    
    attr_accessor :file
    attr_accessor :hint 
    attr_reader :attributes
    
    def initialize(attributes={})
      self.hint= attributes.delete(:hint)
      @attributes = attributes
      @attributes.each do |key,value|
              #generate methods for instance object by attributes
              singleton_class.class_eval do
                define_method(key) { self.attributes[key] } unless method_defined? key
                define_method("#{key}=") { |new_value|  @attributes[key] = new_value } unless method_defined? "#{key}="
              end
        end
    end

    def persisted?
      false
    end

  end
end
