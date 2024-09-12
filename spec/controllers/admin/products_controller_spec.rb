require "rails_helper"

RSpec.describe Admin::ProductsController, type: :controller do
  let!(:admin_user) { create(:admin_user) }
  let!(:category) { Category.create(category_name: "Category") }
  let!(:product1) { create(:product, category: category, product_name: "Product 1") }
  let!(:product2) { create(:product, category: category, product_name: "Product 2") }

  before do
    sign_in admin_user
  end

  describe "GET #index" do
    before { get :index, params: { q: { product_name_cont: "Product" } } }
    it "assigns the correct query and stores it in session" do
      expect(assigns(:q)).to be_a(Ransack::Search)
      expect(assigns(:q).result).to include(product1, product2)

      expect(assigns(:query)).to eq("Product")
      expect(session[:search_query]).to eq("Product")
    end

    it "assigns paginated products to @products_search and pagy object" do
      expect(assigns(:products_search)).to include(product1, product2)
      expect(assigns(:pagy)).to be_a(Pagy)
    end

    it "render the index template" do
      get :index, params: { q: { product_name_cont: "" } }
      expect(response).to render_template(:index)
    end
  end

  describe "GET #new" do
    it "assigns a new product to @product and render the new template" do
      get :new
      expect(assigns(:product)).to be_a_new(Product)
      expect(response).to render_template(:new)
    end
  end

  describe "POST #create" do
    context "with valid attributes" do
      it "create a new product" do
        expect {
          post :create, params: { product: attributes_for(:product, category_id: category.id) }
        }.to change(Product, :count).by(1)
      end

      it "redirect to the index path with success flash" do
        post :create, params: { product: attributes_for(:product, category_id: category.id) }
        expect(flash[:success]).to eq(I18n.t("admin.products.create.messages.success"))
        expect(response).to redirect_to(admin_products_path(q: { product_name_cont: assigns(:product).product_name }))
      end
    end

    context "with invalid attributes" do
      it "does not create a new product" do
        expect {
          post :create, params: { product: attributes_for(:product, category_id: nil) }
        }.not_to change(Product, :count)
      end

      it "re-render the new template with error flash" do
        post :create, params: { product: attributes_for(:product, category_id: nil) }
        expect(flash[:error]).to eq(I18n.t("admin.products.create.messages.error"))
        expect(response).to render_template(:new)
      end
    end
  end

  describe "GET #edit" do
    context "when product is found" do
      it "assigns the requested product to @product" do
        get :edit, params: { id: product1.id }
        expect(assigns(:product)).to eq(product1)
        expect(response).to render_template(:edit)
      end
    end
  
    context "when product is not found" do
      it "redirect to index with a flash warning" do
        get :edit, params: { id: 0 }
        expect(flash[:warning]).to eq(I18n.t("flash.not_found_product"))
        expect(response).to redirect_to(admin_products_path(q: { product_name_cont: session[:search_query] }))
      end
    end
  end

  describe "PATCH #update" do
    context "with valid attributes" do
      it "update the product" do
        patch :update, params: { id: product1.id, product: { product_name: "Updated Product 1" } }
        product1.reload
        expect(product1.product_name).to eq("Updated Product 1")
      end

      it "redirect to the index path with success flash" do
        session[:search_query] = "Product 1"
        patch :update, params: { id: product1.id, product: { product_name: "Updated Product 1" } }
        expect(flash[:success]).to eq(I18n.t("admin.products.update.messages.success"))
        expect(response).to redirect_to(admin_products_path(q: { product_name_cont: "Product 1" }))
        expect(session[:search_query]).to be_nil
      end
    end

    context "with invalid attributes" do
      it "does not update the product" do
        patch :update, params: { id: product1.id, product: { product_name: nil } }
        expect(product1.reload.product_name).not_to be_nil
      end

      it "re-render the edit template with error flash" do
        patch :update, params: { id: product1.id, product: { product_name: nil } }
        expect(flash[:error]).to eq(I18n.t("admin.products.update.messages.error"))
        expect(response).to render_template(:edit)
      end
    end
  end

  describe "DELETE #destroy" do
    context "when product is successfully destroyed" do
      it "delete the product" do
        expect {
          delete :destroy, params: { id: product1.id }
        }.to change(Product, :count).by(-1)
      end

      it "redirect to the index with success flash" do
        session[:search_query] = "Product 1"
        delete :destroy, params: { id: product1.id }
        expect(flash[:success]).to eq(I18n.t("admin.products.destroy.messages.success"))
        expect(response).to redirect_to(admin_products_path(q: { product_name_cont: "Product 1" }))
        expect(session[:search_query]).to be_nil
      end
    end

    context "when product cannot be destroyed" do
      before do
        allow_any_instance_of(Product).to receive(:destroy).and_return(false)
      end

      it "does not delete the product" do
        expect {
          delete :destroy, params: { id: product1.id }
        }.not_to change(Product, :count)
      end

      it "displays error flash" do
        delete :destroy, params: { id: product1.id }
        expect(flash[:error]).to eq(I18n.t("admin.products.destroy.messages.error"))
        expect(session[:search_query]).to be_nil
      end
    end
  end
end
