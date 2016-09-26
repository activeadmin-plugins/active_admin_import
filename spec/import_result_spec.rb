# frozen_string_literal: true
require 'spec_helper'

describe ActiveAdminImport::ImportResult do
  context 'failed_message' do
    let(:import_result) { ActiveAdminImport::ImportResult.new }

    before do
      Author.create(name: 'John', last_name: 'Doe')
      Author.create(name: 'Jane', last_name: 'Roe')

      @result = double \
        failed_instances: [
          # {:last_name=>["has already been taken"]}
          Author.create(name: 'Jim', last_name: 'Doe'),
          # {:name=>["can't be blank"], :last_name=>["has already been taken"]}
          Author.create(name: nil,   last_name: 'Doe')
        ]
    end

    it 'should work without any failed instances' do
      expect(import_result.failed_message).to eq('')
    end

    it 'should work' do
      import_result.add(@result, 4)
      expect(import_result.failed_message)
        .to eq(
          "Last name has already been taken - Doe ; Name can't be blank - , Last name has already been taken - Doe"
        )
    end

    it 'should work on limit param' do
      import_result.add(@result, 4)
      expect(import_result.failed_message(limit: 1)).to eq('Last name has already been taken - Doe')
    end
  end
end
