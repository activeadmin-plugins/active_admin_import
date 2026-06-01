# frozen_string_literal: true

# Formtastic 6 (AA 4) keeps the same DOM IDs as Formtastic 4 (AA 3) for this
# form, so one selector set serves both — branch here if a future AA shifts an ID.
module ImportFormSelectors
  module_function

  SELECTORS = {
    form_id: 'new_active_admin_import_model',
    file_input_id: 'active_admin_import_model_file',
    file_input_css: 'input#active_admin_import_model_file',
    submit_css: '#active_admin_import_model_submit_action input',
    import_button_text: 'Import',
    import_link_text: 'Import Authors'
  }.freeze

  def form_id            = SELECTORS[:form_id]
  def form_css           = "##{form_id}"
  def file_input_id      = SELECTORS[:file_input_id]
  def file_input_css     = SELECTORS[:file_input_css]
  def submit_css         = SELECTORS[:submit_css]
  def import_button_text = SELECTORS[:import_button_text]
  def import_link_text   = SELECTORS[:import_link_text]
end
