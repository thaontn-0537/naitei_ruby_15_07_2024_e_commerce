class ApplicationController < ActionController::Base
  include SessionsHelper
  include Pagy::Backend

  def default_url_options
    {locale: I18n.locale}
  end

  before_action :set_search_query

  def set_search_query
    @q = Product.ransack(params[:q])
  end

  around_action :switch_locale

  def switch_locale &action
    locale = params[:locale] || I18n.default_locale
    I18n.with_locale(locale, &action)
  end
end
