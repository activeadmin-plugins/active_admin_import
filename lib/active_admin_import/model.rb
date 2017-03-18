# encoding: utf-8
# frozen_string_literal: true

require 'rchardet'
require 'zip'

module ActiveAdminImport
  class Model
    include ActiveModel::Model
    include ActiveModel::Validations
    include ActiveModel::Validations::Callbacks

    module CONST
      ZIP_TYPE = 'application/zip'.freeze
      TMP_FILE = 'active-admin-import-unzipped'.freeze
      CSV_TYPES = %w(
        text/csv
        text/x-csv
        text/x-comma-separated-values
        text/comma-separated-values
        application/csv
        application/vnd.ms-excel
        application/vnd.msexcel
        text/tsv
        text/x-tsv
        text/tab-separated-values
        text/x-tab-separated-values
      ).freeze
    end

    validates :file, presence: {
      message: ->(*_) { I18n.t('active_admin_import.no_file_error') }
    }, unless: ->(me) { me.new_record? }

    validate :correct_content_type, if: ->(me) { me.file.present? }
    validate :file_contents_present, if: ->(me) { me.file.present? }

    before_validation :unzip_file, if: ->(me) { me.archive? && me.allow_archive? }
    before_validation :encode_file, if: ->(me) { me.force_encoding? && me.file.present? }

    attr_reader :attributes

    def initialize(args = {})
      @new_record = true
      @attributes = {}
      assign_attributes(default_attributes.merge(args), true)
    end

    def assign_attributes(args = {}, new_record = false)
      @attributes.merge!(args)
      @new_record = new_record
      args.keys.each do |key|
        define_methods_for(key.to_sym)
      end if args.is_a?(Hash)
    end

    def read_attribute_for_validation(key)
      @attributes[key.to_sym]
    end

    def default_attributes
      {
        allow_archive: true,
        csv_headers: [],
        file: nil,
        force_encoding: 'UTF-8',
        hint: ''
      }
    end

    def allow_archive?
      attributes[:allow_archive].present?
    end

    def new_record?
      @new_record.present?
    end

    def force_encoding?
      attributes[:force_encoding].present?
    end

    def persisted?
      false
    end

    def archive?
      file_type == CONST::ZIP_TYPE
    end

    alias to_hash attributes

    protected

    def file_path
      if file.is_a? ActionDispatch::Http::UploadedFile
        file.tempfile.path
      else
        file.path
      end
    end

    def encode_file
      data = File.read(file_path)
      File.open(file_path, 'w') do |f|
        f.write(encode(data))
      end
    end

    def unzip_file
      Zip::File.open(file_path) do |zip_file|
        self.file = Tempfile.new(CONST::TMP_FILE)
        data = zip_file.entries.select(&:file?).first.get_input_stream.read
        file << data
        file.close
      end
    end

    def csv_allowed_types
      CONST::CSV_TYPES
    end

    def correct_content_type
      return if file.blank? ||
          file.is_a?(Tempfile) ||
          (csv_allowed_types.include? file_type)
      errors.add(:file, I18n.t('active_admin_import.file_format_error'))
    end

    def file_contents_present
      return unless File.zero?(file_path)
      errors.add(:file, I18n.t('active_admin_import.file_empty_error'))
    end

    def file_type
      if file.is_a? ActionDispatch::Http::UploadedFile
        file.content_type.chomp
      else
        ''
      end
    end

    def define_methods_for(attr_name)
      # generate methods for instance object by attributes
      singleton_class.class_eval do
        define_set_method(attr_name)
        define_get_method(attr_name)
      end
    end

    def encode(data)
      data = content_encode(data) if force_encoding?
      data = data.encode(
        'UTF-8',
        invalid: :replace, undef: :replace, universal_newline: true
      )
      begin
        data.sub("\xEF\xBB\xBF", '') # bom
      rescue StandardError => _
        data
      end
    end

    def detect_encoding?
      force_encoding == :auto
    end

    def dynamic_encoding(data)
      CharDet.detect(data)['encoding']
    end

    def content_encode(data)
      encoding_name = if detect_encoding?
                        dynamic_encoding(data)
                      else
                        force_encoding.to_s
                      end
      data.force_encoding(encoding_name)
    end

    class <<self
      def define_set_method(attr_name)
        return if method_defined? attr_name
        define_method(attr_name) { attributes[attr_name] }
      end

      def define_get_method(attr_name)
        return if method_defined? "#{attr_name}="
        define_method("#{attr_name}=") { |new_value| @attributes[attr_name] = new_value }
      end
    end
  end
end
