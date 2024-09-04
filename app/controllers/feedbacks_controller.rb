class FeedbacksController < ApplicationController
  def create
    feedback_params = build_feedback_params

    if feedback_exists?(feedback_params)
      flash[:error] = t "flash.feedbacks.already_exists"
    else
      feedback = Feedback.new(feedback_params)

      if feedback.save
        flash[:success] = t "flash.feedbacks.success"
      else
        flash[:error] = t "flah.feedbacks.error"
      end
    end
    redirect_to order_path(feedback.order)
  end

  private

  def build_feedback_params
    params
      .require(:feedback)
      .permit(:rating, :comment, :product_id, :order_id, :image)
      .merge(user_id: current_user.id)
  end

  def feedback_exists? feedback_params
    Feedback.exists?(
      user_id: feedback_params[:user_id],
      product_id: feedback_params[:product_id],
      order_id: feedback_params[:order_id]
    )
  end
end
