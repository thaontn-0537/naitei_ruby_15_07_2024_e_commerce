module OrdersHelper
  def calculate_item_total cart
    product = Product.find_by id: cart.product_id
    cart.quantity * product.price
  end

  def calculate_total_amount order_items_ids
    order_items_ids.reduce(0) do |total_amount, id|
      cart = Cart.find_by(id:)
      total_amount + calculate_item_total(cart)
    end
  end

  def status_name status
    t "orders.statuses.#{status}"
  end

  def format_price price
    number_with_delimiter price, unit: "đ"
  end

  def orders_sort_path sort_by, status, direction: "asc"
    if current_user.role_admin?
      admin_orders_path(sort_by:, status:, direction:)
    else
      orders_path(sort_by:, status:, direction:)
    end
  end

  def display_action_column? orders, current_user
    current_user.role_admin? && orders.any? do |order|
      %w(preparing in_transit).include? order.status.to_sym
    end ||
      orders.any?{|order| order.status.to_sym == :pending}
  end

  def address_options_for_select addresses
    if addresses.empty?
      options_for_select([], nil)
    else
      options = addresses.map{|a| [a.place, a.place]}
      default_address_place = addresses.find(&:default)&.place ||
                              addresses.first.place
      options_for_select(options, default_address_place)
    end
  end

  def status_classes order, status_value
    current_status_value = Order.statuses[order.status.to_sym]

    if order.status_cancelled?
      status_value == Order.statuses[:cancelled] ? "cancelled" : ""
    else
      status_value <= current_status_value ? "completed" : ""
    end
  end

  def line_classes order, index, statuses
    if order.status_cancelled?
      ""
    elsif index < statuses.length - 1
      next_status_value = statuses[index + 1][:value]
      current_status_value = Order.statuses[order.status.to_sym]

      if next_status_value <= current_status_value
        "completed"
      else
        ""
      end
    else
      ""
    end
  end

  def order_statuses
    Order.statuses.keys.map do |status_key|
      {
        name: status_name(status_key),
        value: Order.statuses[status_key]
      }
    end
  end

  def sortable column, title = nil
    title ||= t(".#{column}")
    direction = if column.to_s == params[:sort_by] &&
                   params[:direction] == "desc"
                  "asc"
                else
                  "desc"
                end
    link_to title, orders_sort_path(
      column, params[:status] || :all, direction:
    )
  end
end
