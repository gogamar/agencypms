require "test_helper"

class BedroomsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @bedroom = bedrooms(:one)
  end

  test "should get index" do
    get bedrooms_url
    assert_response :success
  end

  test "should get new" do
    get new_bedroom_url
    assert_response :success
  end

  test "should create bedroom" do
    assert_difference("Bedroom.count") do
      post bedrooms_url, params: { bedroom: { bedroom_type: @bedroom.bedroom_type, vrental_id: @bedroom.vrental_id } }
    end

    assert_redirected_to bedroom_url(Bedroom.last)
  end

  test "should show bedroom" do
    get bedroom_url(@bedroom)
    assert_response :success
  end

  test "should get edit" do
    get edit_bedroom_url(@bedroom)
    assert_response :success
  end

  test "should update bedroom" do
    patch bedroom_url(@bedroom), params: { bedroom: { bedroom_type: @bedroom.bedroom_type, vrental_id: @bedroom.vrental_id } }
    assert_redirected_to bedroom_url(@bedroom)
  end

  test "should destroy bedroom" do
    assert_difference("Bedroom.count", -1) do
      delete bedroom_url(@bedroom)
    end

    assert_redirected_to bedrooms_url
  end
end
