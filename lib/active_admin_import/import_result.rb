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
        # Avoid an error when ActiveModel::Errors#keys is deprecated.
        if Gem::Version.new(Rails.version) >= Gem::Version.new('6.2')
          failed_values = errors.attribute_names.map do |key|
            key == :base ? nil : record.public_send(key)
          end
        else
          failed_values = errors.keys.map do |key|
            key == :base ? nil : record.public_send(key)
          end
        end
        errors.full_messages.zip(failed_values).map { |ms| ms.compact.join(' - ') }.join(', ')
      end.join(' ; ')
    end
  end
end
