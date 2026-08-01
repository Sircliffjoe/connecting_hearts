class AddReceiptDetailsToDonations < ActiveRecord::Migration[8.1]
  def change
    add_column :donations, :receipt_url, :string
    add_column :donations, :depositor_name, :string
    add_column :donations, :notes, :text
  end
end
