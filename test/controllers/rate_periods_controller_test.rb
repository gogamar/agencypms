require "test_helper"

class RatePeriodsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @rate_period = rate_periods(:one)
  end

  test "should get index" do
    get rate_periods_url
    assert_response :success
  end

  test "should get new" do
    get new_rate_period_url
    assert_response :success
  end

  test "should create rate_period" do
    assert_difference("RatePeriod.count") do
      post rate_periods_url, params: { rate_period: { arrival_day: @rate_period.arrival_day, firstnight: @rate_period.firstnight, lastnight: @rate_period.lastnight, min_stay: @rate_period.min_stay, name: @rate_period.name } }
    end

    assert_redirected_to rate_period_url(RatePeriod.last)
  end

  test "should show rate_period" do
    get rate_period_url(@rate_period)
    assert_response :success
  end

  test "should get edit" do
    get edit_rate_period_url(@rate_period)
    assert_response :success
  end

  test "should update rate_period" do
    patch rate_period_url(@rate_period), params: { rate_period: { arrival_day: @rate_period.arrival_day, firstnight: @rate_period.firstnight, lastnight: @rate_period.lastnight, min_stay: @rate_period.min_stay, name: @rate_period.name } }
    assert_redirected_to rate_period_url(@rate_period)
  end

  test "should destroy rate_period" do
    assert_difference("RatePeriod.count", -1) do
      delete rate_period_url(@rate_period)
    end

    assert_redirected_to rate_periods_url
  end
end
