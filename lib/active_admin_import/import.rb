require 'csv'
module ActiveAdminImport
  module Import
    def self.import resource, file, options={}
      validate = options.delete(:validate) || true
      data = ::CSV.parse file.read, {:headers => true, :col_sep => options[:col_sep] || ',' }
      headers = data.first.headers
      headers =  Hash[headers.zip(headers.map { |el| el.underscore.gsub(/\s+/, '_') })]
      result = []
      #wrap into transaction to make it faster
       resource.transaction do
         options[:before_import].call(data) if options[:before_import].is_a?(Proc)
         result = resource.import headers.values, data.map(&:fields), :validate => validate
         options[:after_import].call(data) if options[:after_import].is_a?(Proc)
      end

      result
    end
  end
end
