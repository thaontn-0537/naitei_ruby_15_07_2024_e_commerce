class CartsController < ApplicationController
  before_action :find_cart_item, only: %i(update destroy)
  before_action :set_order_items_ids, only: :index
  before_action :logged_in_user, :init_data, only: %i(create update destroy)

  def index
    @pagy, @carts = pagy(
      current_user.carts.includes(:product),
      items: Settings.page_10
    )
    reset_selection
  end

  def create
    create_cart
    if @cart.save
      respond_to do |format|
        format.turbo_stream
        format.html{redirect_to product_path @cart.product}
      end
    else
      flash[:warning] = t "flash.add_to_cart_failed"
      redirect_to product_path params[:product_id]
    end
  end

  def update
    process_cart_update(params[:action_type]) if params[:action_type].present?

    handle_selection

    respond_to do |format|
      format.turbo_stream
      format.html{redirect_to product_path @cart.product}
    end
  end

  def destroy
    remove_cart_item_from_selection if selected_items.include?(@cart&.id)
    @cart.destroy
    update_count_and_total

    respond_to do |format|
      format.turbo_stream
      format.html{redirect_to product_path @cart.product}
    end
  end

  def update_selection
    find_cart_item_for_selection
    handle_selection

    respond_to do |format|
      format.turbo_stream
      format.html{redirect_to carts_path}
    end
  end

  private

  def handle_selection
    if params[:is_checked].present? || selected_items.include?(@cart&.id)
      update_selected_items
      update_selected_total
    end
    update_count_and_total
  end

  def remove_cart_item_from_selection
    items = selected_items
    items.delete @cart.id
    cookies[:cartitemids] = items.to_json

    update_selected_total
  end

  def update_count_and_total
    @count = selected_items_count || 0
    @total = formatted_selected_total || 0
  end

  def reset_selection
    cookies[:cartitemids] = [].to_json
    cookies[:total] = 0
    @count = 0
    @total = 0
  end

  def update_selected_items
    cart_id = params[:cart_id].to_i
    items = selected_items

    if params[:is_checked] == "true"
      items << cart_id unless items.include? cart_id
    else
      items.delete cart_id
    end

    cookies[:cartitemids] = items.to_json
  end

  def update_selected_total
    selected_carts = Cart.by_id selected_items
    total = selected_carts.sum{|cart| cart.quantity * cart.product.price}
    cookies[:total] = total.to_s
  end

  def selected_items
    JSON.parse(cookies[:cartitemids].presence || "[]").map(&:to_i)
  end

  def selected_items_count
    selected_items.size
  end

  def formatted_selected_total
    cookies[:total].to_i
  end

  def find_cart_item
    @cart = current_user.carts.find_by product_id: params[:product_id]
  end

  def find_cart_item_for_selection
    @cart = current_user.carts.find_by id: params[:cart_id]
  end

  def process_cart_update action_type
    case action_type.to_sym
    when :increment
      increment_cart_quantity
    when :decrement
      decrement_cart_quantity
    end
  end

  def increment_cart_quantity
    stock = @cart.product.stock
    if @cart.quantity < stock
      @cart.update quantity: @cart.quantity + 1
    else
      flash[:error] = t ".not_enough_stock"
    end
  end

  def decrement_cart_quantity
    @cart.update quantity: @cart.quantity - 1
    @cart.destroy if @cart.quantity <= 0
  end

  def create_cart
    product = Product.find params[:product_id]
    if product.stock.zero?
      flash[:error] = t "flash.no_stock"
    elsif @cart.new_record? || @cart.quantity <= 0
      @cart = current_user.carts.new(product_id: params[:product_id],
                                     quantity: 1)
    else
      @cart.quantity += 1
    end
  end

  def init_data
    @product_id = params[:product_id]
    @cart ||= current_user.carts.find_or_initialize_by product_id: @product_id
    @cart.quantity ||= 0
  end

  def logged_in_user
    return if user_signed_in?

    flash[:warning] = t ".login_required"
    redirect_to login_path
  end
end
