require 'csv'
module ActiveAdminImport
  class Importer

    attr_reader :resource, :options, :result, :model
    attr_accessor :csv_lines, :headers

    OPTIONS = [
        :validate,
        :on_duplicate_key_update,
        :ignore,
        :timestamps,
        :before_import,
        :after_import,
        :before_batch_import,
        :after_batch_import,
        :headers_rewrites,
        :batch_size,
        :batch_transaction,
        :csv_options
    ].freeze

    def initialize(resource, model, options)
      @resource = resource
      @model = model
      @headers = model.respond_to?(:csv_headers) ? model.csv_headers : []
      assign_options(options)
    end

    def import_result
      @import_result ||= ImportResult.new
    end

    def file
      @model.file
    end

    def cycle(lines)
      @csv_lines = CSV.parse(lines.join, @csv_options)
      import_result.add(batch_import, lines.count)
    end

    def import
      run_callback(:before_import)
      process_file
      run_callback(:after_import)
      import_result
    end

    def import_options
      @import_options ||= options.slice(:validate, :on_duplicate_key_update, :ignore, :timestamps, :batch_transaction)
    end

    def batch_replace(header_key, options)
      index = header_index(header_key)
      csv_lines.map! do |line|
        from = line[index]
        line[index] = options[from] if options.has_key?(from)
        line
      end
    end

    def values_at(header_key)
      csv_lines.collect { |line| line[header_index(header_key)] }.uniq
    end

    def header_index(header_key)
      headers.values.index(header_key)
    end

    protected

    def process_file
      lines, batch_size = [], options[:batch_size].to_i
      File.open(file.path) do |f|
        # capture headers if not exist
        prepare_headers { CSV.parse(f.readline, @csv_options).first }
        f.each_line do |line|
          lines << line if line.present?
          if lines.size == batch_size || f.eof?
            cycle(lines)
            lines = []
          end
        end
      end
      cycle(lines) unless lines.blank?
    end

    def prepare_headers
      headers = self.headers.present? ? self.headers.map(&:to_s) : yield
      @headers = Hash[headers.zip(headers.map { |el| el.underscore.gsub(/\s+/, '_') })].with_indifferent_access
      @headers.merge!(options[:headers_rewrites].symbolize_keys.slice(*@headers.symbolize_keys.keys))
      @headers
    end

    def run_callback(name)
      options[name].call(self) if options[name].is_a?(Proc)
    end

    def batch_import
      batch_result = nil
      @resource.transaction do
        run_callback(:before_batch_import)
        batch_result = resource.import(headers.values, csv_lines, import_options)
        raise ActiveRecord::Rollback if import_options[:batch_transaction] && batch_result.failed_instances.any?
        run_callback(:after_batch_import)
      end
      batch_result
    end

    def assign_options(options)
      @options = {batch_size: 1000, validate: true}.merge(options.slice(*OPTIONS))
      detect_csv_options
    end

    def detect_csv_options
      @csv_options = if model.respond_to?(:csv_options)
                       model.csv_options
                     else
                       options[:csv_options] || {}
                     end.reject { |_, value| value.blank? }
    end

  end
end
