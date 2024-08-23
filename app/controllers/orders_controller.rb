class OrdersController < ApplicationController
  include OrdersHelper
  before_action :set_order_items_ids, :set_default_data, :set_order_items,
                only: %i(order_info create)
  before_action :set_orders, only: %i(index)
  before_action :find_order, only: %i(update_status show)

  def index
    @orders = @orders.sorted_by(
      params[:sort_by] || :updated_at, params[:direction] || :desc
    )
    @pagy, @orders = pagy @orders, limit: Settings.page_10
  end

  def show
    if @order.user_id == current_user.id
      @pagy, @order_items = pagy(
        @order.order_items,
        items: Settings.page_10
      )
    else
      flash[:error] = t "flash.order_not_found"
      redirect_to root_path
    end
  end

  def order_info
    @order = Order.new
  end

  def create
    @order = @current_user.orders.new order_params
    @order.total = calculate_total_amount @order_items_ids

    if @order.valid?
      process_order
    else
      flash.now[:error] = t "orders.order_info.messages.failed"
      render :order_info, status: :unprocessable_entity
    end
  end

  def set_orders
    @orders = fetch_orders
    @current_status = determine_current_status
    @orders_count = @current_user.orders.recently_updated
  end

  def update_status
    unless @order.status_pending? &&
           params[:status].to_sym == :cancelled
      return
    end

    cancel_order
    redirect_to request.referer || orders_path
  end

  private

  def set_default_data
    @current_user = current_user
    @addresses = @current_user.addresses.sort_by_time
    @address = @current_user.addresses.default_or_latest
  end

  def set_order_items
    @order_items = @order_items_ids.map do |id|
      cart = Cart.find_by(id:)
      product = Product.find_by id: cart.product_id
      item_total = calculate_item_total(cart)
      {cart:, product:, item_total:}
    end
  end

  def order_params
    params.require(:order).permit Order::ORDER_PARAMS
  end

  def add_order_items
    @order_items.each do |item|
      @order.order_items.build(
        product_id: item[:product].id,
        quantity: item[:cart].quantity,
        price: item[:product].price
      )
    end
  end

  def update_product_stock_and_sold order_items
    order_items.each do |item|
      product = item.product
      next if product.nil?

      amount = item.quantity
      if product.stock.nil?
        product.update(stock: 0)
        product.increment(stock_amount: 0, sold_amount: amount)
        product.update(stock: nil)
      else
        product.increment(stock_amount: -amount, sold_amount: amount)
      end
    end
  end

  def process_order
    add_order_items
    if @order.save
      update_product_stock_and_sold @order.order_items
      @order.update(paid_at: Time.current)
      Cart.by_id(@order_items_ids).destroy_all
      cookies.delete(:cartitemids)
      cookies.delete(:total)
      flash[:success] = t "orders.order_info.messages.success"
      redirect_to orders_path
    else
      render :order_info, status: :unprocessable_entity
    end
  end

  def fetch_orders
    if status_valid?
      current_user.orders.by_status(params[:status].to_sym)
    else
      current_user.orders
    end
  end

  def status_valid?
    params[:status].present? && Order.statuses.key?(params[:status].to_sym)
  end

  def determine_current_status
    if status_valid?
      params[:status].to_sym
    else
      :all
    end
  end

  def cancel_order
    if @order.cancel_order(role: :user, refuse_reason: params[:refuse_reason])
      flash[:success] = t "admin.orders.orders_list.update_to_cancelled"
    else
      flash[:error] = t "admin.orders.orders_list.update_failed"
    end
  end

  def find_order
    @order = Order.find_by(id: params[:id])
    return if @order

    flash[:error] = t "orders.not_found"
    redirect_to orders_path
  end
end
