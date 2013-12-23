module ActiveAdminImport
  class Model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations

    validates :file, :presence => {:message => Proc.new { I18n.t('active_admin_import.no_file_error') }} ,
              :if => proc{|me| me.assigned?}
    validate :correct_content_type

    attr_reader :attributes

    def initialize(attributes={})
      assign_attributes default_attributes.merge(attributes)
    end

    def assign_attributes(attributes = {})
      @assigned = true
      @attributes = (@attributes || {}).merge(attributes)
      attributes.each do |key, value|
        key = key.to_sym
        #generate methods for instance object by attributes
        singleton_class.class_eval do
          define_method(key) { self.attributes[key] } unless method_defined? key
          define_method("#{key}=") { |new_value| @attributes[key] = new_value } unless method_defined? "#{key}="
        end
      end
    end

    def read_attribute_for_validation(key)
       @attributes[key.to_sym]
     end

    def default_attributes
      {
         hint: '',
         file: nil
      }
    end

    def  assigned?
      @assigned
    end

    def to_hash
       @attributes
    end

    def allowed_types
      [
          'text/csv',
          'text/x-csv',
          'text/comma-separated-values',
          'application/csv',
          'application/vnd.ms-excel',
          'application/vnd.msexcel'
      ]
    end

    def correct_content_type
      if @attributes[:file].present?
        errors.add(:file, I18n.t('active_admin_import.file_format_error')) unless allowed_types.include? file.try(:content_type).try(:chomp)
      end
    end

    def persisted?
      false
    end

  end
end
