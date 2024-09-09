module ApplicationHelper
  include Pagy::Frontend
  def full_title page_title = ""
    base_title = t "defaults.name"
    page_title.blank? ? base_title : "#{page_title} | #{base_title}"
  end

  def resized_image record
    return "logo.png" unless record.image.attached?

    begin
      record.image.variant(resize_to_fill: [Settings.list.image_size,
                                            Settings.list.image_size]).processed
    rescue ActiveStorage::InvariableError
      "logo.png"
    end
  end

  def order_item_image order, path
    if order.order_items.any? &&
       order.order_items.first.product&.image&.attached?
      product = order.order_items.first.product
      link_to image_tag(resized_image(product), alt: product.product_name,
      class: "product-image"), path
    else
      link_to image_tag("logo.png", alt: t(".no_image"),
      class: "product-image"), path
    end
  end

  def product_path_for_role product
    if current_user.role_admin?
      admin_products_path q: {product_name_cont: product.product_name}
    else
      product_path(product)
    end
  end

  def skip_header?
    controller_name.to_sym == :registrations ||
      controller_name.to_sym == :sessions
  end

  def skip_container?
    controller_name.to_sym == :registrations ||
      controller_name.to_sym == :sessions
  end

  def format_currency amount
    number_to_currency(amount, unit: "₫", format: "%n %u", precision: 0,
    delimiter: ".", separator: ",")
  end

  def formatted_data_for_chart data
    data.transform_values{|value| format_currency value}
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

  def nav_link_to name, path, html_options = {}
    active_class = "active" if current_page? path
    html_options[:class] =
      "#{html_options[:class]} nav-link #{active_class}".strip
    link_to name, path, html_options
  end
end
