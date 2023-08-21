require "test_helper"

class TouristsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @tourist = tourists(:one)
  end

  test "should get index" do
    get tourists_url
    assert_response :success
  end

  test "should get new" do
    get new_tourist_url
    assert_response :success
  end

  test "should create tourist" do
    assert_difference("Tourist.count") do
      post tourists_url, params: { tourist: { address: @tourist.address, country: @tourist.country, country_code: @tourist.country_code, document: @tourist.document, email: @tourist.email, firstname: @tourist.firstname, lastname: @tourist.lastname, phone: @tourist.phone } }
    end

    assert_redirected_to tourist_url(Tourist.last)
  end

  test "should show tourist" do
    get tourist_url(@tourist)
    assert_response :success
  end

  test "should get edit" do
    get edit_tourist_url(@tourist)
    assert_response :success
  end

  test "should update tourist" do
    patch tourist_url(@tourist), params: { tourist: { address: @tourist.address, country: @tourist.country, country_code: @tourist.country_code, document: @tourist.document, email: @tourist.email, firstname: @tourist.firstname, lastname: @tourist.lastname, phone: @tourist.phone } }
    assert_redirected_to tourist_url(@tourist)
  end

  test "should destroy tourist" do
    assert_difference("Tourist.count", -1) do
      delete tourist_url(@tourist)
    end

    assert_redirected_to tourists_url
  end
end
