class CreateConnectingHeartsCoreModels < ActiveRecord::Migration[8.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.string :email, null: false, index: { unique: true }
      t.string :password_digest, null: false
      t.string :role, null: false, default: "admin"

      t.timestamps
    end

    create_table :support_requests do |t|
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :preferred_contact_method, default: "email"
      t.string :support_category, null: false
      t.string :session_format, default: "online"
      t.text :situation_description, null: false
      t.boolean :consent_given, default: false
      t.string :status, default: "pending"
      t.text :notes
      t.references :reviewed_by, foreign_key: { to_table: :users }, null: true

      t.timestamps
    end

    create_table :volunteer_applications do |t|
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :role_interest, null: false
      t.text :skills
      t.string :availability
      t.string :status, default: "pending"
      t.text :notes

      t.timestamps
    end

    create_table :partnership_inquiries do |t|
      t.string :organization_name, null: false
      t.string :contact_person, null: false
      t.string :email, null: false
      t.string :phone
      t.string :partnership_type, null: false
      t.text :message, null: false
      t.string :status, default: "pending"

      t.timestamps
    end

    create_table :events do |t|
      t.string :title, null: false
      t.string :edition_number
      t.datetime :event_date
      t.string :location
      t.string :theme
      t.text :description
      t.boolean :featured, default: false
      t.string :registration_link
      t.integer :capacity
      t.string :image_url

      t.timestamps
    end

    create_table :event_registrations do |t|
      t.references :event, foreign_key: true
      t.string :full_name, null: false
      t.string :email, null: false
      t.string :phone
      t.string :attendance_type, default: "in_person"
      t.string :status, default: "confirmed"

      t.timestamps
    end

    create_table :stories do |t|
      t.string :title, null: false
      t.string :category
      t.text :summary
      t.text :body, null: false
      t.string :image_url
      t.boolean :published, default: true
      t.boolean :featured, default: false

      t.timestamps
    end

    create_table :resources do |t|
      t.string :title, null: false
      t.string :category, null: false
      t.string :resource_type, null: false
      t.text :summary
      t.text :content
      t.string :file_url
      t.string :external_link
      t.boolean :published, default: true

      t.timestamps
    end

    create_table :donations do |t|
      t.string :donor_name
      t.string :donor_email, null: false
      t.decimal :amount, precision: 12, scale: 2, null: false
      t.string :currency, default: "NGN"
      t.string :purpose, null: false
      t.string :payment_reference, null: false
      t.string :status, default: "pending"

      t.timestamps
    end

    create_table :testimonials do |t|
      t.string :author_name, null: false
      t.string :relationship_status
      t.text :quote, null: false
      t.string :edition_title
      t.boolean :featured, default: false
      t.boolean :approved, default: true

      t.timestamps
    end
  end
end
