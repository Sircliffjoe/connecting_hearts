module ApplicationHelper
  def safe_image_path(url)
    return "" if url.blank?
    if url.start_with?("http://", "https://")
      url
    else
      filename = File.basename(url)
      begin
        image_path(filename)
      rescue StandardError
        url
      end
    end
  end
end
