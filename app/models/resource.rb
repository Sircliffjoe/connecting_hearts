class Resource < ApplicationRecord
  CATEGORIES = ["Singles", "Marriage", "Communication", "Emotional Wellbeing", "Family & Parenting", "Education"].freeze
  TYPES = ["Article", "Video", "Audio Podcast", "PDF Guide", "FAQ"].freeze

  validates :title, presence: true
  validates :category, presence: true, inclusion: { in: CATEGORIES }
  validates :resource_type, presence: true, inclusion: { in: TYPES }

  serialize :gallery_images, coder: JSON

  scope :published, -> { where(published: true).order(created_at: :desc) }
  scope :by_category, ->(cat) { cat.present? ? where(category: cat) : all }
  scope :by_type, ->(t) { t.present? ? where(resource_type: t) : all }

  def main_image
    image_url.presence || ActionController::Base.helpers.image_path("pic120.jpeg")
  end

  def extra_images
    imgs = if gallery_images.is_a?(Array) && gallery_images.reject(&:blank?).present?
             gallery_images.reject(&:blank?).first(4)
           elsif gallery_images.is_a?(String) && gallery_images.present?
             (JSON.parse(gallery_images) rescue []).reject(&:blank?).first(4)
           else
             []
           end

    if imgs.empty?
      [
        ActionController::Base.helpers.image_path("pic113.jpeg"),
        ActionController::Base.helpers.image_path("pic114.jpeg"),
        ActionController::Base.helpers.image_path("pic115b.jpeg"),
        ActionController::Base.helpers.image_path("pic117.jpeg")
      ]
    else
      imgs
    end
  end
end
