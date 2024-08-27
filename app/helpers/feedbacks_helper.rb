module FeedbacksHelper
  def feedback_for_order_item order_item, user
    product = Product.with_deleted.find(order_item.product_id)
    Feedback.find_by(
      product_id: product.id,
      user_id: user.id,
      created_at: time_range_for(order_item)
    )
  end

  def feedback_for_current_order order_item
    order_item.feedback
  end

  def render_feedback_or_form order, order_item
    product = Product.with_deleted.find(order_item.product_id)
    existing_feedback = Feedback.find_by(
      product_id: product.id,
      user_id: current_user.id,
      order_id: order.id
    )

    if existing_feedback
      render partial: "feedbacks/feedbacks_infor", locals: {
        order_item:, feedback: existing_feedback
      }
    else
      render partial: "feedbacks/feedbacks_form", locals: {
        order:, order_item:
      }
    end
  end

  def can_repurchase? order
    order.order_items.all? do |item|
      Feedback.exists?(
        product_id: item.product_id,
        user_id: current_user.id,
        order_id: order.id
      )
    end
  end

  def can_review? order
    order.order_items.any? do |item|
      !Feedback.exists?(
        product_id: item.product_id,
        user_id: current_user.id,
        order_id: order.id
      )
    end
  end

  private

  def time_range_for order_item
    order_item.created_at.beginning_of_day..order_item.created_at.end_of_day
  end

  def sortreviews column, title = nil
    title ||= t(".#{column}")
    direction = if column.to_s == params[:sort_by] &&
                   params[:direction] == "desc"
                  "asc"
                else
                  "desc"
                end
    link_to title,
            product_path(@product,
                         sort_by: column, direction:),
            class: "btn btn-secondary"
  end
end
