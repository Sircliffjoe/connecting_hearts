class CreateContactInquiries < ActiveRecord::Migration[8.1]
  def change
    create_table :contact_inquiries do |t|
      t.string :name, null: false
      t.string :email, null: false
      t.string :subject, null: false
      t.text :message, null: false
      t.string :status, default: "pending"

      t.timestamps
    end
  end
end
