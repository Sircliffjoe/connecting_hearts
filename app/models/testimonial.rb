class Testimonial < ApplicationRecord
  validates :author_name, presence: true
  validates :quote, presence: true

  scope :approved, -> { where(approved: true) }
  scope :featured, -> { where(approved: true, featured: true) }
end
