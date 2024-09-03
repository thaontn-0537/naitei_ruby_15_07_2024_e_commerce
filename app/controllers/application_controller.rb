class ApplicationController < ActionController::Base
  before_action :configure_sign_up_params, if: :devise_controller?

  include Pagy::Backend

  def default_url_options
    {locale: I18n.locale}
  end

  before_action :set_search_query
  before_action :current_user

  def set_search_query
    @q = Product.ransack(params[:q])
  end

  around_action :switch_locale

  def switch_locale &action
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end

  def set_order_items_ids
    @order_items_ids = if cookies[:cartitemids].present?
                         JSON.parse(cookies[:cartitemids]).map(&:to_i)
                       else
                         []
                       end
  end

  protected

  def configure_sign_up_params
    added_attrs = User::ACCOUNT_PARAMS
    devise_parameter_sanitizer.permit :sign_up, keys: added_attrs
  end
end
