require 'spec_helper'

describe 'import', type: :feature do

  shared_examples 'successful inserts' do |encoding, csv_file_name|
    let(:options) do
      attributes = { force_encoding: encoding }
      { template_object: ActiveAdminImport::Model.new(attributes) }
    end

    before do
      upload_file!(csv_file_name)
    end

    it "should import file with many records" do
      expect(page).to have_content "Successfully imported 2 authors"
      expect(Author.count).to eq(2)
      Author.all.each do |author|
        expect(author).to be_valid
        expect(author.name).to be_present
        expect(author.last_name).to be_present
      end
    end
  end

  def with_zipped_csv(name, &block)

    zip_file = File.expand_path("./spec/fixtures/files/#{name}.zip")

    begin
      Zip::File.open(zip_file, Zip::File::CREATE) do |z|
        z.add "#{name}.csv", File.expand_path("./spec/fixtures/files/#{name}.csv")
      end
      instance_eval &block
    ensure
      File.delete zip_file rescue nil
    end
  end

  def upload_file!(name, ext='csv')
    attach_file('active_admin_import_model_file', File.expand_path("./spec/fixtures/files/#{name}.#{ext}"))
    find_button('Import').click
  end

  context "posts index" do
    before do
      Author.create!(name: "John", last_name: "Doe")
      Author.create!(name: "Jane", last_name: "Roe")
    end

    context "for csv for particular author" do
      let(:author) { Author.take }

      shared_examples 'successful inserts for author' do
        it "should use predefined author_id" do
          expect(Post.where(author_id: author.id).count).to eq(Post.count)
        end

        it "should be imported" do
          expect(Post.count).to eq(2)
          expect(page).to have_content "Successfully imported 2 posts"
        end
      end

      context "no headers" do
        before do
          add_post_resource(template_object: ActiveAdminImport::Model.new(author_id: author.id,
                                                                          csv_headers: [:title, :body, :author_id]),
                            validate: true,
                            before_batch_import: ->(importer) do
                              importer.csv_lines.map! { |row| row << importer.model.author_id }
                            end
          )

          visit "/admin/posts/import"
          upload_file!(:posts_for_author_no_headers)
        end
        include_examples 'successful inserts for author'
      end

      context "with headers" do
        before do
          add_post_resource(template_object: ActiveAdminImport::Model.new(author_id: author.id),
                            validate: true,
                            before_batch_import: ->(importer) do
                              importer.csv_lines.map! { |row| row << importer.model.author_id }
                              importer.headers.merge!({ :'Author Id' => :author_id })
                            end
          )

          visit "/admin/posts/import"
          upload_file!(:posts_for_author)
        end
        include_examples 'successful inserts for author'
      end
    end

    context "for csv with author name" do
      before do
        add_post_resource(
            validate: true,
            template_object: ActiveAdminImport::Model.new,
            headers_rewrites: { :'Author Name' => :author_id },
            before_batch_import: ->(importer) do
              authors_names = importer.values_at(:author_id)
              # replacing author name with author id
              authors = Author.where(name: authors_names).pluck(:name, :id)
              #{"Jane" => 2, "John" => 1}
              options = Hash[*authors.flatten]
              importer.batch_replace(:author_id, options)
            end
        )
        visit "/admin/posts/import"
        upload_file!(:posts)
      end

      it "should resolve author_id by author name" do
        Post.all.each do |post|
          expect(Author.where(id: post.author.id)).to be_present
        end
      end

      it "should be imported" do
        expect(Post.count).to eq(2)
        expect(page).to have_content "Successfully imported 2 posts"
      end
    end
  end

  context "authors index" do
    before do
      add_author_resource
    end

    it "should navigate to import page" do
      #todo: removing this causes  undefined method `ransack' for #<ActiveRecord::Relation []>
      allow_any_instance_of(Admin::AuthorsController).to receive(:find_collection).and_return(Author.all)
      visit '/admin/authors'
      find_link('Import Authors').click
      expect(current_path).to eq("/admin/authors/import")
    end
  end

  context "with custom block" do
    before do
      add_author_resource({}) do
        flash[:notice] = 'some custom message'
      end
      visit '/admin/authors/import'
    end

    it "should display notice from custom block" do
      upload_file!(:author)
      expect(page).to have_content "some custom message"
    end

  end

  context "authors already exist" do
    before do
      Author.create!(id: 1, name: "Jane", last_name: "Roe")
      Author.create!(id: 2, name: "John", last_name: "Doe")
    end

    context "having authors with the same Id" do
      before do
        add_author_resource(
            before_batch_import: ->(importer) do
              Author.where(id: importer.values_at("id")).delete_all
            end
        )
        visit "/admin/authors/import"
        upload_file!(:authors_with_ids)
      end

      it "should replace authors" do
        expect(page).to have_content "Successfully imported 2 authors"
        expect(Author.count).to eq(2)
      end

      it "should replace authors by id" do
        expect(Author.find(1).name).to eq("John")
        expect(Author.find(2).name).to eq("Jane")
      end
    end
  end

  context "with valid options" do

    let(:options) { {} }

    before do
      add_author_resource(options)
      visit '/admin/authors/import'
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

    context "with hint defined" do
      let(:options) do
        { template_object: ActiveAdminImport::Model.new(hint: "hint") }
      end
      it "renders hint at upload page" do
        expect(page).to have_content options[:template_object].hint
      end
    end

    context "when importing file" do

      [:empty, :only_headers].each do |file|
        context "when #{file} file" do
          it "should render warning" do
            upload_file!(file)
            expect(page).to have_content I18n.t('active_admin_import.file_empty_error')
            expect(Author.count).to eq(0)
          end
        end
      end

      context "when no file" do
        it "should render error" do
          find_button('Import').click
          expect(Author.count).to eq(0)
          expect(page).to have_content I18n.t('active_admin_import.no_file_error')
        end
      end

      context "auto detect encoding" do
        include_examples 'successful inserts',
                         :auto,
                         :authors_win1251_win_endline
      end

      context "Win1251" do
        include_examples 'successful inserts',
                         'windows-1251',
                         :authors_win1251_win_endline
      end

      context "BOM" do
        it "should import file with many records" do
          upload_file!(:authors_bom)
          expect(page).to have_content "Successfully imported 2 authors"
          expect(Author.count).to eq(2)
        end
      end

      context "with headers" do
        it "should import file with many records" do
          upload_file!(:authors)
          expect(page).to have_content "Successfully imported 2 authors"
          expect(Author.count).to eq(2)
        end

        it "should import file with 1 record" do
          upload_file!(:author)
          expect(page).to have_content "Successfully imported 1 author"
          expect(Author.count).to eq(1)
        end
      end

      context "without headers" do
        context "with known csv headers" do
          let(:options) do
            attributes = { csv_headers: ['Name', 'Last name', 'Birthday'] }
            { template_object: ActiveAdminImport::Model.new(attributes) }
          end

          it "should import file" do
            upload_file!(:authors_no_headers)
            expect(page).to have_content "Successfully imported 2 authors"
            expect(Author.count).to eq(2)
          end
        end

        context "with unknown csv headers" do
          it "should render error" do
            upload_file!(:authors_no_headers)
            expect(page).to have_content "Error:"
            expect(Author.count).to eq(0)
          end
        end
      end

      context "with invalid data insert" do
        it "should render error" do
          upload_file!(:authors_invalid_db)
          expect(page).to have_content "Error:"
          expect(Author.count).to eq(0)
        end
      end

      context "with invalid records" do
        context "with validation" do
          it "should render error" do
            upload_file!(:author_invalid)
            expect(page).to have_content "Failed to import 1 author"
            expect(Author.count).to eq(0)
          end
        end

        context "without validation" do
          let(:options) { { validate: false } }
          it "should render error" do
            upload_file!(:author_invalid)
            expect(page).to have_content "Successfully imported 1 author"
            expect(Author.count).to eq(1)
          end
        end
      end

      context "when zipped" do
        context "when allowed" do
          it "should import file" do
            with_zipped_csv(:authors) do
              upload_file!(:authors, :zip)
              expect(page).to have_content "Successfully imported 2 authors"
              expect(Author.count).to eq(2)
            end
          end
        end

        context "when not allowed" do
          let(:options) do
            attributes = { allow_archive: false }
            { template_object: ActiveAdminImport::Model.new(attributes) }
          end
          it "should render error" do
            with_zipped_csv(:authors) do
              upload_file!(:authors, :zip)
              expect(page).to have_content I18n.t('active_admin_import.file_format_error')
              expect(Author.count).to eq(0)
            end
          end
        end
      end

      context "with different header attribute names" do
        let(:options) do
          { headers_rewrites: { :'Second name' => :last_name } }
        end

        it "should import file" do
          upload_file!(:author_broken_header)
          expect(page).to have_content "Successfully imported 1 author"
          expect(Author.count).to eq(1)
        end
      end

      context "with semicolons separator" do
        let(:options) do
          attributes = { csv_options: { col_sep: ";" } }
          { template_object: ActiveAdminImport::Model.new(attributes) }
        end

        it "should import file" do
          upload_file!(:authors_with_semicolons)
          expect(page).to have_content "Successfully imported 2 authors"
          expect(Author.count).to eq(2)
        end
      end
    end

    context "with callback procs options" do
      let(:options) do
        {
            before_import: ->(_) { true },
            after_import: ->(_) { true },
            before_batch_import: ->(_) { true },
            after_batch_import: ->(_) { true }
        }
      end

      it "should call each callback" do
        expect(options[:before_import]).to receive(:call).with(kind_of(ActiveAdminImport::Importer))
        expect(options[:after_import]).to receive(:call).with(kind_of(ActiveAdminImport::Importer))
        expect(options[:before_batch_import]).to receive(:call).with(kind_of(ActiveAdminImport::Importer))
        expect(options[:after_batch_import]).to receive(:call).with(kind_of(ActiveAdminImport::Importer))
        upload_file!(:authors)
        expect(Author.count).to eq(2)
      end
    end

  end

  context "with invalid options" do
    let(:options) { { invalid_option: :invalid_value } }

    it "should raise TypeError" do
      expect { add_author_resource(options) }.to raise_error(ArgumentError)
    end

  end

end