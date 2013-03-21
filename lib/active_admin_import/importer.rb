require 'csv'
module ActiveAdminImport
  class Importer

    attr_reader :resource, :file, :options , :extra_options , :result ,
    :cycle_data, :headers , :csv_lines

    def store
          p headers.values
        p csv_lines
          p @resource
      result = @resource.transaction do
        options[:before_batch_import].call(self) if options[:before_batch_import].is_a?(Proc)


        result = resource.import headers.values, csv_lines, {
            :validate => options[:validate],
            :on_duplicate_key_update => options[:on_duplicate_key_update],
            :ignore => options[:ignore],
            :timestamps => options[:timestamps]
        }
        options[:after_batch_import].call(self) if options[:after_batch_import].is_a?(Proc)
        result
      end
      {:imported => csv_lines.count -  result.failed_instances.count , :failed => result.failed_instances}
    end

    def prepare_headers(headers)

      @headers =  Hash[headers.zip(headers.map { |el| el.underscore.gsub(/\s+/, '_') })]
      p @headers
      p options
      @headers.merge!(options[:headers_rewrites])
      p @headers
      @headers
    end

    def initialize resource, file, options , extra_options = nil
      @resource = resource
      p @resource, "<<<<"
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
      @extra_options = extra_options
    end

    def cycle(lines)
       @csv_lines = CSV.parse(lines.join)
       @result.merge!(self.store){|key,val1,val2| val1+val2}
    end

    def import
      options[:before_import].call(self) if options[:before_import].is_a?(Proc)
      lines = []
      batch_size = options[:batch_size].to_i
      IO.foreach(file.path) do |line|
        if headers.empty?
          prepare_headers(CSV.parse(line).first)
        else
          lines << line
          if lines.size >= batch_size
            cycle lines
            lines = []
          end
        end
      end
      cycle(lines) unless lines.blank?
      options[:after_import].call(self) if options[:after_import].is_a?(Proc)
      result
    end
  end
end
