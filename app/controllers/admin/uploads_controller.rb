module Admin
  class UploadsController < ApplicationController
    def create
      file = params[:file]
      if file.present?
        begin
          if ENV["CLOUDINARY_URL"].present? || (ENV["CLOUDINARY_CLOUD_NAME"].present? && ENV["CLOUDINARY_API_KEY"].present?)
            upload_options = { resource_type: "auto", folder: "connecting_hearts" }
            response = Cloudinary::Uploader.upload(file.tempfile.path, upload_options)
            render json: { url: response["secure_url"], public_id: response["public_id"], success: true }
          else
            filename = "#{Time.current.to_i}_#{file.original_filename.parameterize}"
            uploads_dir = Rails.root.join("public", "uploads")
            FileUtils.mkdir_p(uploads_dir)
            file_path = uploads_dir.join(filename)
            File.open(file_path, "wb") { |f| f.write(file.read) }
            render json: { url: "/uploads/#{filename}", filename: filename, success: true }
          end
        rescue => e
          render json: { error: e.message, success: false }, status: :unprocessable_entity
        end
      else
        render json: { error: "No file provided", success: false }, status: :bad_request
      end
    end
  end
end
