module ApplicationHelper
  include Pagy::Frontend
  def full_title page_title = ""
    base_title = t "defaults.name"
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end

  def resized_image record
    return unless record.image.attached?

    record.image.variant(resize_to_fill: [Settings.list.image_size,
                                          Settings.list.image_size]).processed
  end
end
