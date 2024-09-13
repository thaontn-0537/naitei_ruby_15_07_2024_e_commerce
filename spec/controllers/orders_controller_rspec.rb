require "rails_helper"

RSpec.describe OrdersController, type: :controller do
  let(:user){create(:user)}
  let(:order){create(:order, user: user, status: :pending)}
  let(:address){create(:address, user: user, default: true)}
  let(:product){create(:product)}
  let(:cart){create(:cart, user: user, product: product)}
  let!(:order_items){create_list(:order_item, 3, order: order, product: product)}
  let!(:order_items_ids){[cart.id]}
  let(:valid_order_params) do
    {
      order: {
        place: "HN",
        payment_method: "momo",
        user_name: user.user_name,
        user_phone: user.phone,
        total: 200
      }
    }
  end
  let(:invalid_order_params) do
    {
      order: {
        place: "",
        payment_method: "momo",
        user_name: user.user_name,
        user_phone: user.phone,
        total: 200
      }
    }
  end
  let(:valid_status){"delivered"}
  let(:invalid_status){"invalid_status"}

  before do
    sign_in user
  end

  describe "GET #index" do
    before do
      get :index
    end

    it "assigns the sorted and paginated orders to @orders" do
      expect(assigns(:orders)).to be_present
    end

    it "renders the index template" do
      expect(response).to render_template(:index)
    end
  end

  describe "GET #show" do
    before do
      get :show, params:{id: order.id}
    end

    context "when order is found" do
      it "assigns the order" do
        expect(assigns(:order)).to eq(order)
      end
    end

    it "assigns the requested order to @order" do
      expect(assigns(:order)).to eq(order)
    end

    it "paginates order items" do
      expect(assigns(:pagy)).to be_present
      expect(assigns(:order_items)).to be_present
    end

    it "builds feedback for each order item" do
      expect(assigns(:order_items_with_feedback)).to all(include(:order_item, :feedback))
    end

    it "renders the show template" do
      expect(response).to render_template(:show)
    end
  end

  describe "GET #order_info" do
    before do
      get :order_info, params:{order_items_ids: order_items_ids}
    end

    it "sets default data" do
      expect(assigns(:addresses)).to match_array(user.addresses.sort_by_time)
      expect(assigns(:address)).to eq(user.addresses.default_or_latest)
    end

    it "initializes a new order" do
      expect(assigns(:order)).to be_a_new(Order)
    end

    it "renders the order_info template" do
      expect(response).to render_template(:order_info)
    end
  end

  describe "POST #create" do
    context "with valid parameters" do
      it "creates a new order and redirects to orders_path" do
        post :create, params: valid_order_params

        expect(response).to redirect_to(orders_path)
        expect(flash[:success]).to eq I18n.t("orders.order_info.messages.success")
      end
    end

    context "with invalid parameters" do
      it "does not create a new order and renders order_info with unprocessable_entity status" do
        post :create, params: invalid_order_params

        expect(response).to render_template(:order_info)
        expect(response).to have_http_status(:unprocessable_entity)
        expect(flash[:error]).to eq I18n.t("orders.order_info.messages.failed")
      end
    end
  end

  describe "PATCH #update_status" do
    let(:pending_order){create(:order, user: user, status: :pending)}
    let(:preparing_order){create(:order, user: user, status: :preparing)}
    let(:delivered_order){create(:order, user: user, status: :delivered)}

    context "when order status is pending and status is cancelled" do
      before do
        patch :update_status, params:{id: pending_order.id, status: "cancelled", refuse_reason: "Customer request"}
      end

      it "updates the order status to cancelled" do
        expect(pending_order.reload.status).to eq "cancelled"
      end

      it "sets a success flash message" do
        expect(flash[:success]).to eq I18n.t("admin.orders.orders_list.update_to_cancelled")
      end

      it "redirects to the previous page or orders path" do
        expect(response).to redirect_to(request.referer || orders_path)
      end
    end

    context "when order status is not pending or status is not cancelled" do
      before do
        patch :update_status, params:{id: preparing_order.id, status: "cancelled", refuse_reason: "Customer request"}
      end

      it "does not update the order status" do
        expect(preparing_order.reload.status).to eq "preparing"
      end

      it "does not set a flash message" do
        expect(flash[:success]).to be_nil
      end

      it "returns a 204 No Content response" do
        expect(response).to have_http_status(:no_content)
      end
    end

    context "when order status is delivered" do
      before do
        patch :update_status, params:{id: delivered_order.id, status: "cancelled", refuse_reason: "Customer request"}
      end

      it "does not update the order status" do
        expect(delivered_order.reload.status).to eq "delivered"
      end

      it "does not set a flash message" do
        expect(flash[:success]).to be_nil
      end

      it "returns a 204 No Content response" do
        expect(response).to have_http_status(:no_content)
      end
    end
  end

  describe "#determine_current_status" do
    before do
      allow(controller).to receive(:status_valid?).and_return(status_valid)
    end

    context "when status is valid" do
      let(:status_valid){true}

      before do
        allow(controller).to receive_message_chain(:params, :[], :to_sym).and_return(valid_status.to_sym)
      end

      it "returns the status as a symbol" do
        result = controller.send(:determine_current_status)
        expect(result).to eq(valid_status.to_sym)
      end
    end

    context "when status is not valid" do
      let(:status_valid){false}

      it "returns :all" do
        result = controller.send(:determine_current_status)
        expect(result).to eq(:all)
      end
    end
  end
end
