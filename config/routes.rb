# Plugin's routes
# See: http://guides.rubyonrails.org/routing.html

get '/projects/:project_id/issues/export_qr_code' , :to => 'issues#export_qr_code', :as => 'export_qr_code'