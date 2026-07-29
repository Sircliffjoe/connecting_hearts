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

  def page_title(title = nil)
    base_title = "Connecting Hearts for Singles & Married Foundation | Warri, Nigeria"
    if title.present?
      "#{title} | Connecting Hearts Foundation"
    elsif content_for?(:title)
      "#{content_for(:title)} | Connecting Hearts Foundation"
    else
      base_title
    end
  end

  def page_description(default_desc = nil)
    if default_desc.present?
      default_desc
    elsif content_for?(:description)
      content_for(:description)
    else
      "Connecting Hearts for Singles & Married Foundation creates safe spaces, provides free confidential counseling, and supports children from broken families in Warri, Delta State, Nigeria."
    end
  end

  def og_image_url(custom_image = nil)
    raw = custom_image.presence || content_for(:og_image).presence || "pic112.jpeg"

    if raw.start_with?("http://", "https://")
      return raw
    end

    filename = File.basename(raw)

    begin
      path = image_path(filename)
      if path.start_with?("http://", "https://")
        path
      else
        "#{request.base_url}#{path}"
      end
    rescue StandardError
      "#{request.base_url}#{image_path('logo.png')}"
    end
  end
end
