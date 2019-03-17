# frozen_string_literal: true
require 'spec_helper'

describe ActiveAdminImport::ImportResult do
  context 'failed_message' do
    let(:import_result) { ActiveAdminImport::ImportResult.new }


    let(:failed_instances) do
     [
         Author.new(last_name: 'Doe').tap {|r| r.errors.add(:last_name,  :taken) },
         Author.new(name: "", last_name: 'Doe').tap {|r| r.errors.add(:name,  :blank); r.errors.add(:last_name,  :taken)  },
         Author.new.tap {|r| r.errors.add(:base,  'custom') }
     ]
    end

    before do
      @result = double \
        failed_instances: failed_instances
    end

    it 'should work without any failed instances' do
      expect(import_result.failed_message).to eq('')
    end

    it 'should work' do
      import_result.add(@result, 4)
      expect(import_result.failed_message)
        .to eq(
          "Last name has already been taken - Doe ; Name can't be blank - , Last name has already been taken - Doe ; custom"
        )
    end

    it 'should work on limit param' do
      import_result.add(@result, 4)
      expect(import_result.failed_message(limit: 1)).to eq('Last name has already been taken - Doe')
    end
  end
end
