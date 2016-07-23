class AddQrCodeToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :qr_code, :string, default: ''
  end
end