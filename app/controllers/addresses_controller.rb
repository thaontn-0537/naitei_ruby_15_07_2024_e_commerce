class AddressesController < ApplicationController
  def create
    @address = @current_user.addresses.new address_params
    set_default_address if @address.default
    if @address.save
      render_success_response
    else
      render_failure_response
    end
  end

  private

  def address_params
    params.require(:address).permit Address::ADDRESS_PARAMS
  end

  def set_default_address
    @current_user.addresses.update_all(default: false)
  end

  def render_success_response
    flash.now[:success] = t "addresses.messages.success"
    render json: {
      success: true,
      address_id: @address.id,
      place: @address.place
    }
  end

  def render_failure_response
    flash.now[:error] = t "addresses.messages.failed"
    render json: {
      success: false,
      errors: @address.errors.full_messages
    }
  end
end
