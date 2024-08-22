class OrdersController < ApplicationController
  include OrdersHelper
  before_action :set_order_items_ids, :set_default_data, :set_order_items,
                only: %i(order_info create)
  before_action :set_orders, only: %i(index)
  def show
    @order = Order.find params[:id]
    if @order && @order.user_id == current_user.id
      @pagy, @order_items = pagy(
        @order.order_items,
        items: Settings.page_10
      )
    else
      flash[:warning] = t "flash.order_not_found"
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

  def index
    sort_by = params[:sort_by].present? ? params[:sort_by].to_sym : nil

    case sort_by
    when :status
      @orders = @orders.sorted_by_status
    when :created_at
      @orders = @orders.sorted_by_created_at
    end
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

  def process_order
    add_order_items
    if @order.save
      @order.update(paid_at: Time.current)
      Cart.by_id(@order_items_ids).destroy_all
      cookies.delete(:cartitemids)
      cookies.delete(:total)
      flash[:success] = t "orders.order_info.messages.success"
      redirect_to order_path(@order)
    else
      render :order_info, status: :unprocessable_entity
    end
  end

  def set_orders
    if params[:status].present? && Order.statuses.key?(params[:status].to_sym)
      @orders = current_user.orders.by_status(params[:status].to_sym)
      @current_status = params[:status].to_sym
    else
      @orders = current_user.orders
      @current_status = :all
    end
  end
end
