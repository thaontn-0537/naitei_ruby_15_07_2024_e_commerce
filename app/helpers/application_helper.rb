module ApplicationHelper
  def full_title page_title = ""
    base_title = t "defaults.name"
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end

  def logged_in?
    false
  end
end