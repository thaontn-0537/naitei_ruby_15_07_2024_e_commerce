class Ability
  include CanCan::Ability

  def initialize user
    user ||= User.new

    if user.role_admin?
      admin_permissions
    else
      user_permissions user
    end
  end

  private

  def admin_permissions
    can :manage, :all
  end

  def user_permissions user
    cannot :manage, Admin::UsersController
    cannot :manage, Admin::OrdersController
    cannot :manage, Admin::ProductsController
    cannot :manage, Admin::StatisticsController

    can :read, Product
    can :read, Order, user_id: user.id
    can :manage, Order, user_id: user.id
    can :manage, Cart, user_id: user.id
    can %i(update), Order, user_id: user.id
    can :manage, Address, user_id: user.id
    can :create, Feedback
    can :read, Feedback, product_id: Product.where(user_id: user.id)

    can %i(search filter_by_category), Product
  end
end
