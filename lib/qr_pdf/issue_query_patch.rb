module  QrPdf
  module IssueQueryPatch
    def self.included(base)
      base.extend(ClassMethods)

      base.send(:include, InstanceMethods)
      base.class_eval do
        alias_method_chain :available_columns, :qr_code
      end
    end
  end
  module ClassMethods
  end

  module InstanceMethods
    def available_columns_with_qr_code
      if @available_columns.blank?
        @available_columns = available_columns_without_qr_code
        @available_columns << QueryColumn.new(:qr_code, :caption => :qr_code)
      else
        available_columns_without_qr_code
      end
      @available_columns
    end

  end
  module QueryInstanceMethods
    def value_object_with_qr_code(object)
      if name == :qr_code
        "<div class='issue_qrcode' title='#{issue_url(object, host: Setting.host_name) }'></div>".html_safe
      else
        value_object_without_qr_code(object)
      end
    end
  end


  module QueryPatch
    def self.included(base)
      base.send(:include, QueryInstanceMethods)
      base.class_eval do
        include Rails.application.routes.url_helpers
        include ActionView::Helpers::UrlHelper
        alias_method_chain :value_object, :qr_code
      end
    end
  end
end