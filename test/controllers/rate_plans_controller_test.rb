require "test_helper"

class RatePlansControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rate_plan = rate_plans(:one)
  end

  test "should get index" do
    get rate_plans_url
    assert_response :success
  end

  test "should get new" do
    get new_rate_plan_url
    assert_response :success
  end

  test "should create rate_plan" do
    assert_difference("RatePlan.count") do
      post rate_plans_url, params: { rate_plan: { arrival: @rate_plan.arrival, end: @rate_plan.end, min: @rate_plan.min, start: @rate_plan.start } }
    end

    assert_redirected_to rate_plan_url(RatePlan.last)
  end

  test "should show rate_plan" do
    get rate_plan_url(@rate_plan)
    assert_response :success
  end

  test "should get edit" do
    get edit_rate_plan_url(@rate_plan)
    assert_response :success
  end

  test "should update rate_plan" do
    patch rate_plan_url(@rate_plan), params: { rate_plan: { arrival: @rate_plan.arrival, end: @rate_plan.end, min: @rate_plan.min, start: @rate_plan.start } }
    assert_redirected_to rate_plan_url(@rate_plan)
  end

  test "should destroy rate_plan" do
    assert_difference("RatePlan.count", -1) do
      delete rate_plan_url(@rate_plan)
    end

    assert_redirected_to rate_plans_url
  end
end
