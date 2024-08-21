class CartsController < ApplicationController
  before_action :find_cart_item, only: %i(update destroy)
  before_action :set_order_items_ids, only: :index
  before_action :logged_in_user, :init_data, only: %i(create update destroy)

  def index
    @pagy, @carts = pagy(
      current_user.carts.includes(:product),
      items: Settings.page_10
    )
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
    process_cart_update params[:action_type]

    respond_to do |format|
      format.turbo_stream
      format.html{redirect_to product_path @cart.product}
    end
  end

  def destroy
    @cart.destroy
    respond_to do |format|
      format.turbo_stream
      format.html{redirect_to product_path @cart.product}
    end
  end

  private

  def find_cart_item
    @cart = current_user.carts.find_by product_id: params[:product_id]
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
    @cart.update quantity: @cart.quantity + 1
  end

  def decrement_cart_quantity
    @cart.update quantity: @cart.quantity - 1
    @cart.destroy if @cart.quantity <= 0
  end

  def create_cart
    if @cart.new_record? || @cart.quantity <= 0
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
    return if logged_in?

    flash[:warning] = t ".login_required"
    redirect_to login_path
  end
end
