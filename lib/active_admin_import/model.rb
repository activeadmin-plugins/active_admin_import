module ActiveAdminImport
  class Model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    validates :file, presence: {message: Proc.new { I18n.t('active_admin_import.no_file_error') }},
              unless: proc { |me| me.new_record? }

    validate :correct_content_type

    before_validation :unarchive_file, if: proc { |me| me.archive? }

    attr_reader :attributes

    def initialize(args={})
      @new_record = true
      @attributes = {}
      assign_attributes(default_attributes.merge(args) , true)
    end

    def assign_attributes(args = {}, new_record = false)
      @attributes.merge!(args)
      @new_record = new_record
      args.each do |key, value|
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
      {hint: '', file: nil, csv_headers: []}
    end

    def new_record?
      !!@new_record
    end

    def to_hash
      @attributes
    end

    def persisted?
      false
    end

    def archive?
      file_type == 'application/zip'
    end

    protected

    def unarchive_file
      Zip::ZipFile.open(self.file.tempfile.path) do |zip_file|
         self.file = Tempfile.new("active-admin-import-unzipped")
         self.file << zip_file.entries.select{|f| f.file? }.first.get_input_stream.read.encode( 'UTF-8', invalid: :replace, undef: :replace )
         self.file.close
      end
    end


    def csv_allowed_types
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
      unless file.blank? || file.is_a?(Tempfile)
        errors.add(:file, I18n.t('active_admin_import.file_format_error')) unless csv_allowed_types.include? file_type
      end
    end

    def file_type
      file.try(:content_type).try(:chomp)
    end
  end
end


