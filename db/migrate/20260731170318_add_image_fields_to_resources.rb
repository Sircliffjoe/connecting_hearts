class AddImageFieldsToResources < ActiveRecord::Migration[8.1]
  def change
    add_column :resources, :image_url, :string
    add_column :resources, :gallery_images, :text
  end
end
