module ActiveAdminImport
  class ImportResult
    attr_reader :failed, :total

    def initialize
      @failed = []
      @total = 0
    end

    def add(result, qty)
      @failed += result.failed_instances
      @total+=qty
    end

    def imported_qty
      total - failed.count
    end

    def has_imported?
      imported_qty > 0
    end

    def has_failed?
      @failed.any?
    end

    def empty?
      total == 0
    end

    def failed_message
      failed.map{|record|
        errors = record.errors
        (errors.full_messages.zip errors.keys.map{|k| record.send k}).map{|ms| ms.join(' - ')}.join(', ')
      }.join(" ; ")
    end
  end
end
