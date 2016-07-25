Redmine::Plugin.register :redmine_qr_issue do
  name 'Redmine Qr Issue plugin'
  author 'Bilel KEDIDI'
  description 'This is a plugin show a QR code for issue path'
  version '0.0.1'
  author_url 'http://github.com/bilel-kedidi'
end

class Hooks < Redmine::Hook::ViewListener
  # This just renders the partial in
  # app/views/hooks/my_plugin/_view_issues_form_details_bottom.rhtml
  # The contents of the context hash is made available as local variables to the partial.
  #
  # Additional context fields
  #   :issue  => the issue this is edited
  #   :f      => the form object to create additional fields

  render_on :view_issues_show_details_bottom, :partial=> 'issues/issue_qr'
  render_on :view_issues_sidebar_issues_bottom, :partial=> 'issues/sidebar_issue'
end

Rails.application.config.to_prepare do
  Redmine::Export::PDF::ITCPDF.send(:include, QrPdf::PdfPatch)
  Redmine::Export::PDF::IssuesPdfHelper.send(:include, QrPdf::PdfHelperPatch)
  IssuesController.send(:include, QrPdf::IssuesControllerPatch)
  IssueQuery.send(:include, QrPdf::IssueQueryPatch)
  QueryColumn.send(:include, QrPdf::QueryPatch)
end
