module Admin
  class UploadsController < ApplicationController
    def create
      file = params[:file]
      if file.present?
        begin
          if cloudinary_configured?
            upload_options = { resource_type: "auto", folder: "connecting_hearts" }
            response = Cloudinary::Uploader.upload(file.tempfile.path, upload_options)
            render json: { url: response["secure_url"], public_id: response["public_id"], success: true }
          elsif Rails.env.production?
            render json: { error: "Cloudinary is not configured on the production server. Please set CLOUDINARY_URL or CLOUDINARY_CLOUD_NAME, CLOUDINARY_API_KEY, and CLOUDINARY_API_SECRET environment variables.", success: false }, status: :unprocessable_entity
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

    private

    def cloudinary_configured?
      ENV["CLOUDINARY_URL"].present? || 
        (ENV["CLOUDINARY_CLOUD_NAME"].present? && ENV["CLOUDINARY_API_KEY"].present? && ENV["CLOUDINARY_API_SECRET"].present?)
    end
  end
end

