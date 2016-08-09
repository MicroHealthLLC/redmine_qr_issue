module QrPdf
  module IssuesControllerPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        before_filter :authorize, :except => [:index, :new, :create, :export_qr_code]
      end
    end
  end

  module ClassMethods

  end

  module InstanceMethods
    def export_qr_code
      require 'prawn/labels'
      require 'rqrcode_png'
      @project = Project.find(params[:project_id]) unless params[:project_id].blank?
      retrieve_query
      sort_init(@query.sort_criteria.empty? ? [['id', 'desc']] : @query.sort_criteria)
      sort_update(@query.sortable_columns)
      @query.sort_criteria = sort_criteria.to_a


      if @query.valid?
        @issues = @query.issues

        qr_code_urls = @issues.map{|issue|
          {
              id: issue.id,
              url: issue_url(issue),
              subject: "#{issue.id}: #{issue.subject}"
          }
        }
        storage_path = Redmine::Configuration['attachments_storage_path'] || File.join(Rails.root, "files")
        path = storage_path + "/qr_codes"
        unless File.directory?(path)
          FileUtils.mkdir_p(path)
        end

        Prawn::Labels.types = {
            "AverySheet" => {
                "paper_size" => "A4",
                "columns"    => 3,
                "rows"       => 7,
                'top_margin': 43.9,
                'bottom_margin': 43.9,
                'left_margin': 19.843,
                'right_margin': 19.843,
                'column_gutter': 8.504,
                'row_gutter': 0,
            }}
        labels = Prawn::Labels.render(qr_code_urls, :type => "AverySheet") do |pdf, hash|
          image = path + "/issue_#{hash[:id]}.png"
          unless FileTest.exist?(image)

            qr = RQRCode::QRCode.new( hash[:url], :level => :h )
            png = qr.to_img
            png.resize(70,  70).save(image)
          end
          subject = hash[:subject]
          pdf.image image
          pdf.text subject
        end
        send_data labels, :filename => "qr_codes.pdf", :type => "application/pdf"
      end

    rescue ActiveRecord::RecordNotFound
      render_404
    end
  end
end