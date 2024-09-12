require "rails_helper"

RSpec.describe Order, type: :model do
  describe "associations" do
    it{is_expected.to belong_to(:user)}
    it{is_expected.to have_many(:order_items).dependent(:destroy)}
    it{is_expected.to have_many(:feedbacks).dependent(:destroy)}
  end

  describe "validations" do
    context "for total" do
      it{is_expected.to validate_presence_of(:total)}
      it{is_expected.to validate_numericality_of(:total).is_greater_than_or_equal_to(Settings.value.min_numeric)}
    end

    context "for place" do
      it{is_expected.to validate_presence_of(:place)}
    end

    context "for user_phone" do
      it{is_expected.to validate_length_of(:user_phone).is_equal_to(Settings.value.phone)}
      it{is_expected.to allow_value("0766257688").for(:user_phone)}
    end

    context "for payment_method" do
      it{is_expected.to validate_presence_of(:payment_method)}
    end

    context "for status" do
      it{is_expected.to validate_presence_of(:status)}
    end

    context "when status is cancelled" do
      before{allow(subject).to receive(:status_cancelled?).and_return(true)}
      it{is_expected.to validate_presence_of(:refuse_reason)}
    end
  end

  describe "scopes" do
    describe ".by_status" do
      let!(:order1){create(:order, status: :pending)}
      let!(:order2){create(:order, status: :delivered)}

      context "when status is valid" do
        it "returns orders with the specified status" do
          expect(Order.by_status("pending")).to include(order1)
          expect(Order.by_status("pending")).not_to include(order2)
        end
      end

      context "when status is invalid" do
        it "returns all orders" do
          expect(Order.by_status("invalid_status")).to include(order1, order2)
          expect(Order.by_status(nil)).to include(order1, order2)
        end
      end
    end

    describe ".sorted_by" do
      let!(:order1){create(:order, status: :pending)}
      let!(:order2){create(:order, status: :delivered)}

      it "sorts orders by the specified field and direction" do
        expect(Order.sorted_by("status", "asc")).to eq([order1, order2])
      end
    end

    describe ".with_ids" do
      let!(:order1){create(:order)}
      let!(:order2){create(:order)}
      let!(:order3){create(:order)}

      it "returns orders with the specified ids" do
        ids = [order1.id, order3.id]
        expect(Order.with_ids(ids)).to match_array([order1, order3])
      end
    end

    describe ".recently_updated" do
      let!(:order1){create(:order, updated_at: 2.days.ago)}
      let!(:order2){create(:order, updated_at: 1.day.ago)}
      let!(:order3){create(:order, updated_at: Time.zone.now)}

      it "returns orders ordered by updated_at in descending order" do
        expect(Order.recently_updated).to eq([order3, order2, order1])
      end
    end

    describe ".group_by_time_range" do
      before do
        now = Time.zone.now
        create(:order, created_at: now.beginning_of_day + 1.hour, total: 100)
        create(:order, created_at: now.beginning_of_week + 1.day, total: 200)
        create(:order, created_at: now.beginning_of_month + 1.day, total: 300)
        create(:order, created_at: 1.month.ago.beginning_of_month + 1.day, total: 400)
        create(:order, created_at: now.beginning_of_year + 1.month, total: 500)
        create(:order, created_at: 2.years.ago.beginning_of_year + 1.month, total: 600)
      end

      it "returns orders within a specific time range" do
        start_time = Time.zone.now.beginning_of_day
        end_time = Time.zone.now.end_of_day
        expect(Order.group_by_time_range(start_time, end_time, :group_by_day, "%d-%m")).to eq(
         {Time.zone.now.beginning_of_day.strftime("%d-%m") => 100}
        )
      end

      it "returns count of orders for today with total > 0" do
        today_orders = Order.today
        expect(today_orders.select{|_, total| total > 0}.count).to eq(1)
      end

      it "returns count of orders for this week with total > 0" do
        this_week_orders = Order.this_week
        expect(this_week_orders.select{|_, total| total > 0}.count).to eq(2)
      end

      it "returns count of orders for this month with total > 0" do
        this_month_orders = Order.this_month
        expect(this_month_orders.select{|_, total| total > 0}.count).to eq(3)
      end

      it "returns count of orders for last month with total > 0" do
        last_month_orders = Order.last_month
        expect(last_month_orders.select{|_, total| total > 0}.count).to eq(1)
      end

      it "returns count of orders for this year with total > 0" do
        this_year_orders = Order.this_year
        expect(this_year_orders.select{|_, total| total > 0}.count).to eq(3)
      end

      it "returns count of orders for the last three years with total > 0" do
        three_years_orders = Order.three_years
        expect(three_years_orders.select{|_, total| total > 0}.count).to eq(2)
      end

      it "returns orders for this month when period is not recognized" do
        result = Order.by_period("invalid_period")
        expect(result).to match_array(Order.this_month)
      end

      it "returns orders by period" do
        expect(Order.by_period("today").sum{|_, total| total}).to eq(100)
        expect(Order.by_period("this_week").sum{|_, total| total}).to eq(300)
        expect(Order.by_period("this_month").sum{|_, total| total}).to eq(600)
        expect(Order.by_period("last_month").sum{|_, total| total}).to eq(400)
        expect(Order.by_period("this_year").sum{|_, total| total}).to eq(1500)
        expect(Order.by_period("three_years").sum{|_, total| total}).to eq(2100)
      end
    end

    describe ".created_at_month" do
      let(:current_month) { Time.zone.now }
      let(:last_month) { 1.month.ago }

      before do
        create(:order, created_at: current_month.beginning_of_month + 2.days)
        create(:order, created_at: current_month.end_of_month - 1.day)
        create(:order, created_at: last_month.beginning_of_month + 3.days)
      end

      it "returns orders created in the specified month" do
        expect(Order.created_at_month(current_month).count).to eq(2)
        expect(Order.created_at_month(current_month).pluck(:created_at)).to all(be_between(current_month.beginning_of_month, current_month.end_of_month))
        expect(Order.created_at_month(current_month)).not_to include(Order.created_at_month(last_month))
      end
    end
  end

  describe "order calculations" do
    describe ".cal_sum_orders" do
      let!(:order1){create(:order, total: 100)}
      let!(:order2){create(:order, total: 150)}

      it "calculates the sum of orders" do
        orders = Order.where(id: [order1.id, order2.id])
        expect(Order.cal_sum_orders(orders)).to eq(250)
      end
    end
  end

  describe "instance methods" do
    describe "#cancel_order" do
      let(:order){create(:order, status: :pending)}
      let(:refuse_reason){"Customer changed their mind"}

      context "when role is admin" do
        it "updates order status to cancelled with formatted reason" do
          order.cancel_order(role: :admin, refuse_reason: refuse_reason)
          expect(order.reload.status).to eq("cancelled")
          expect(order.refuse_reason).to eq(I18n.t("orders.refuse_reason_by_admin", reason: refuse_reason))
        end
      end

      context "when role is user" do
        it "updates order status to cancelled with formatted reason" do
          order.cancel_order(role: :user, refuse_reason: refuse_reason)
          expect(order.reload.status).to eq("cancelled")
          expect(order.refuse_reason).to eq(I18n.t("orders.refuse_reason_by_user", reason: refuse_reason))
        end
      end

      context "when role is invalid or not provided" do
        it "updates order status to cancelled with the original reason" do
          order.cancel_order(role: :invalid_role, refuse_reason: refuse_reason)
          expect(order.reload.status).to eq("cancelled")
          expect(order.refuse_reason).to eq(refuse_reason)
        end
      end

      context "when an ActiveRecord::RecordInvalid error is raised" do
        before do
          allow(order).to receive(:save!).and_raise(ActiveRecord::RecordInvalid.new(order))
        end

        it "adds an error and returns false" do
          result = order.cancel_order(role: :admin, refuse_reason: refuse_reason)
          expect(result).to be_falsey
          expect(order.errors[:base]).to include(I18n.t("admin.orders.orders_list.update_failed"))
        end
      end
    end
  end
end
