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

  def skip_header?
    action_name == "new" || controller_name == "sessions"
  end

  def skip_container?
    action_name == "new" || controller_name == "sessions"
  end

  def format_currency amount
    number_to_currency(amount, unit: "₫", format: "%n %u", precision: 0,
    delimiter: ".", separator: ",")
  end

  def custom_bootstrap_flash
    flash_messages = flash.map do |type, message|
      next if message.blank?

      type = "success" if type == "notice"
      type = "error"   if type == "alert"
      script_content = "toastr.#{type}('#{ERB::Util.html_escape(message)}');"
      content_tag(:script, script_content)
    end.compact
    safe_join(flash_messages, "\n")
  end

  def toast_type key
    key.to_s.gsub("alert", "error").gsub("notice", "success")
  end
end
