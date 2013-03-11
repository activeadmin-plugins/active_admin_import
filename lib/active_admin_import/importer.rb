require 'csv'
module ActiveAdminImport
  class Importer

    attr_reader :resource, :file, :options , :result

    def store data, headers
      result = @resource.transaction do
        options[:before_batch_import].call(data, headers) if options[:before_batch_import].is_a?(Proc)
        result = resource.import headers, data, {
            :validate => options[:validate],
            :on_duplicate_key_update => options[:on_duplicate_key_update],
            :ignore => options[:ignore],
            :timestamps => options[:timestamps]
        }
        options[:after_batch_import].call(data, headers) if options[:after_batch_import].is_a?(Proc)
        result
      end
      {:imported => data.count -  result.failed_instances.count , :failed => result.failed_instances}
    end

    def prepare_headers(headers)
      Hash[headers.zip(headers.map { |el| el.underscore.gsub(/\s+/, '_') })]
    end

    def initialize resource, file, options
      @resource = resource
      @file = file
      @options = {
          :col_sep => ',',
          :batch_size => 1000,
          :validate => true
      }.merge(options)
      @headers = []
      @result= {
        :failed => [],
        :imported => 0
      }
    end

    def cycle(lines)
       lines = CSV.parse(lines.join)
       @result.merge!(self.store(lines, @headers.values)){|key,val1,val2| val1+val2}
    end

    def import
      options[:before_import].call(@resource, @file, @options) if options[:before_import].is_a?(Proc)
      lines = []
      batch_size = @options[:batch_size].to_i
      IO.foreach(file.path) do |line|
        if @headers.empty?
          @headers = prepare_headers(CSV.parse(line).first)
        else
          lines << line
          if lines.size >= batch_size
            cycle lines
            lines = []
          end
        end
      end
      cycle(lines) unless lines.blank?
      options[:after_import].call(@result) if options[:after_import].is_a?(Proc)
      result
    end
  end
end
