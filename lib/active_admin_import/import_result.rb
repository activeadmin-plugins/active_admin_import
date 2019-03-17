# frozen_string_literal: true
module ActiveAdminImport
  class ImportResult
    attr_reader :failed, :total

    def initialize
      @failed = []
      @total = 0
    end

    def add(result, qty)
      @failed += result.failed_instances
      @total  += qty
    end

    def imported_qty
      total - failed.count
    end

    def imported?
      imported_qty > 0
    end

    def failed?
      failed.any?
    end

    def empty?
      total == 0
    end

    def failed_message(options = {})
      limit = options[:limit] || failed.count
      failed.first(limit).map do |record|
        errors = record.errors
        failed_values = errors.keys.map do |key|
          key == :base ? nil : record.public_send(key)
        end
        errors.full_messages.zip(failed_values).map { |ms| ms.compact.join(' - ') }.join(', ')
      end.join(' ; ')
    end
  end
end
