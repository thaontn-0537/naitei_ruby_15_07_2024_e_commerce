class Admin::StatisticsController < AdminController
  before_action :set_time_period, only: %i(index)
  def index
    @search = Order.ransack params[:q]
    @orders = @search.result

    @revenue_data = @orders.by_period @time_period
    @total_revenue = @revenue_data.values.sum

    @products = Product.top_selling_by_period @time_period_selling
    @chart_data = @products.map do |product|
      [product.product_name, product.total_quantity]
    end
  end

  private
  def set_time_period
    valid_periods = %w(today this_week this_month last_month this_year
                      three_years)
    @time_period = if valid_periods.include?(params[:time_period])
                     params[:time_period]
                   else
                     "this_month"
                   end

    valid_periods_selling = %w(all_time this_week this_month this_year)
    @time_period_selling = if valid_periods_selling
                              .include?(params[:time_period_selling])
                             params[:time_period_selling]
                           else
                             "this_month"
                           end
  end
end
