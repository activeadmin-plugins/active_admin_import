require 'spec_helper'

describe 'import', type: :feature do
  let(:options) { {} }

  before do
    add_author_resource(options)
    visit '/admin/authors/import'
  end

  def upload_file!(name)
    attach_file('active_admin_import_model_file', File.expand_path("./spec/fixtures/csv/#{name}.csv"))
    find_button('Import').click
  end

  it "has valid form" do

    form = find('#new_active_admin_import_model')
    expect(form['action']).to eq("/admin/authors/do_import")
    expect(form['enctype']).to eq("multipart/form-data")
    file_input = form.find("input#active_admin_import_model_file")
    expect(file_input[:type]).to eq("file")
    expect(file_input.value).to be_blank
    submit_input = form.find("#active_admin_import_model_submit_action input")
    expect(submit_input[:value]).to eq("Import")
    expect(submit_input[:type]).to eq("submit")
  end


  context "import file" do

    context "with headers" do

      it "imports file" do
        upload_file!(:authors)
        expect(page).to have_content "Successfully imported 2 authors"
        expect(Author.count).to eq(2)
      end
    end


    context "without headers" do

      it "imports file" do
        allow_any_instance_of(ActiveAdminImport::Model).to receive(:csv_headers).and_return(['Name','Last name','Birthday'])      
        upload_file!(:authors_no_headers)
        expect(page).to have_content "Successfully imported 2 authors"
        expect(Author.count).to eq(2)
      end
    end


  end


end