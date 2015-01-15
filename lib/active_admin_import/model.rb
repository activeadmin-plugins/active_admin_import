module ActiveAdminImport
  class Model
    extend ActiveModel::Naming
    include ActiveModel::Conversion
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    validates :file, presence: {message: Proc.new { I18n.t('active_admin_import.no_file_error') }},
              unless: proc { |me| me.new_record? }

    validate :correct_content_type, if: proc { |me| me.file.present? }
    validate :file_contents_present, if: proc { |me| me.file.present? }


    before_validation :uncompress_file, if: proc { |me| me.archive? && me.allow_archive?  }
    before_validation :encode_file,  if: proc { |me| me.force_encoding? && me.file.present? }

    attr_reader :attributes

    def initialize(args={})
      @new_record = true
      @attributes = {}
      assign_attributes(default_attributes.merge(args), true)
    end


    def assign_attributes(args = {}, new_record = false)
      @attributes.merge!(args)
      @new_record = new_record
      args.keys.each do |key|
        key = key.to_sym
        #generate methods for instance object by attributes
        singleton_class.class_eval do
          define_method(key) { self.attributes[key] } unless method_defined? key
          define_method("#{key}=") { |new_value| @attributes[key] = new_value } unless method_defined? "#{key}="
        end
      end if args.is_a?(Hash)
    end

    def read_attribute_for_validation(key)
      @attributes[key.to_sym]
    end

    def default_attributes
      {hint: '', file: nil, csv_headers: [], allow_archive: true, force_encoding: 'UTF-8'}
    end

    def allow_archive?
      !!@attributes[:allow_archive]
    end

    def new_record?
      !!@new_record
    end

    def force_encoding?
      !!@attributes[:force_encoding]
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

    def file_path
      if file.is_a? ActionDispatch::Http::UploadedFile
        file.tempfile.path
      else
        file.path
      end
    end

    def encode_file
      data = File.read(file_path).encode(force_encoding, invalid: :replace, undef: :replace)
      File.open(file_path, 'w') do |f|
          f.write(data)
      end
    end

    def uncompress_file
      Zip::File.open(file_path) do |zip_file|
        self.file = Tempfile.new("active-admin-import-unzipped")
        data = zip_file.entries.select { |f| f.file? }.first.get_input_stream.read
        data = data.encode(force_encoding, invalid: :replace, undef: :replace) if self.force_encoding?
        self.file << data
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

    def file_contents_present
      errors.add(:file, I18n.t('active_admin_import.file_empty_error')) if File.zero?(file_path)
    end

    def file_type
      if file.is_a? ActionDispatch::Http::UploadedFile
        file.content_type.chomp
      else
        ''
      end
    end
  end
end


